"""Prompt 11 sweep codemod: inline TextStyle blobs -> context.text.<role>.

Same-pixels rules:
- Every prop present in the blob is carried into copyWith verbatim.
- A role is only chosen if its base fontSize/fontWeight/color match what the
  blob would have inherited (ambient default, ListTile title/subtitle ambient,
  or fully-specified blobs).
- const TextStyle blobs, TextSpan blobs without explicit weight+color, blobs
  under DefaultTextStyle.style, and non-literal size/weight exprs are left
  untouched (documented exceptions).
"""
import os
import re
import sys

SCOPE = ["lib/modules", "lib/core/widgets", "lib/core/alerts"]
EXCLUDE = {"lib/modules/jobs/ai_cv/templates/cv_pdf_builder.dart"}
IMPORT_LINE = "import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';"

# role -> (size, weight, colorFamily)
ROLES = {
    "headlineSmall": (22.0, "w700", "heading"),
    "titleLarge": (18.0, "w700", "heading"),
    "titleMedium": (16.0, "w600", "heading"),
    "titleSmall": (15.0, "w600", "heading"),
    "bodyLarge": (16.0, "w400", "heading"),
    "bodyMedium": (14.0, "w400", "heading"),
    "bodySmall": (13.0, "w400", "muted"),
    "labelLarge": (14.0, "w600", "heading"),
    "labelMedium": (12.0, "w500", "muted"),
    "labelSmall": (11.0, "w500", "muted"),
}

# exact (size, weight) -> role (blob color present or colorless-heading ok)
EXACT = {
    (22.0, "w700"): "headlineSmall",
    (18.0, "w700"): "titleLarge",
    (16.0, "w600"): "titleMedium",
    (15.0, "w600"): "titleSmall",
    (16.0, "w400"): "bodyLarge",
    (14.0, "w400"): "bodyMedium",
    (14.0, "w600"): "labelLarge",
    (13.0, "w400"): "bodySmall",
    (12.0, "w500"): "labelMedium",
    (11.0, "w500"): "labelSmall",
}

LIST_TILE_AMBIENT = {
    # widget -> {param: role}
    "ListTile": {"title": "titleMedium", "subtitle": "bodyMedium"},
    "ExpansionTile": {"title": "titleMedium"},
    "SwitchListTile": {"title": "titleMedium", "subtitle": "bodyMedium"},
    "CheckboxListTile": {"title": "titleMedium", "subtitle": "bodyMedium"},
    "RadioListTile": {"title": "titleMedium", "subtitle": "bodyMedium"},
    "VitheyListTile": {"title": "titleSmall", "subtitle": "bodySmall"},
}

CARRY_PROPS = [
    "fontSize", "fontWeight", "color", "backgroundColor", "height",
    "letterSpacing", "wordSpacing", "decoration", "decorationColor",
    "decorationStyle", "decorationThickness", "fontStyle", "fontFamily",
    "fontFeatures", "shadows", "textBaseline", "leadingDistribution",
    "overflow", "inherit", "background", "foreground", "debugLabel",
]

IDENT = r"[A-Za-z_$][A-Za-z0-9_$]*"


def norm_weight(expr):
    m = re.fullmatch(r"FontWeight\.(w[4-9]00|bold|normal)", expr.strip())
    if not m:
        return None
    v = m.group(1)
    return {"bold": "w700", "normal": "w400"}.get(v, v)


def find_blobs(src):
    """Yield (start, end, body, is_const) for every TextStyle(...) blob."""
    out = []
    for m in re.finditer(r"\bTextStyle\s*\(", src):
        i = m.end() - 1
        depth = 0
        j = i
        while j < len(src):
            if src[j] == "(":
                depth += 1
            elif src[j] == ")":
                depth -= 1
                if depth == 0:
                    break
            j += 1
        before = src[: m.start()].rstrip()
        is_const = before.endswith("const")
        out.append((m.start(), j + 1, src[i + 1 : j], is_const))
    return out


def split_props(body):
    """Split a TextStyle body into ordered (name, expr) at top-level commas."""
    props = []
    depth = 0
    cur = ""
    for ch in body:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == "," and depth == 0:
            props.append(cur.strip())
            cur = ""
        else:
            cur += ch
    if cur.strip():
        props.append(cur.strip())
    named = []
    for p in props:
        m = re.match(rf"({IDENT})\s*:\s*(.*)", p, re.S)
        if not m:
            return None  # positional/spread arg — bail out
        named.append((m.group(1), m.group(2).strip()))
    return named


def ambient_scan(src, pos):
    """Walk call stack up to pos; find ListTile-family title/subtitle ambient
    and whether we are inside a TextSpan chain or DefaultTextStyle style."""
    stack = []  # [name, param]
    i = 0
    n = len(src)
    text_span = False
    default_ts_style = False
    ambient = None
    while i < pos:
        ch = src[i]
        if ch == "(":
            # find preceding identifier
            k = i - 1
            while k >= 0 and src[k] in " \t\n\r":
                k -= 1
            name = None
            m = re.search(rf"({IDENT})$", src[: k + 1])
            if m and k >= 0 and not src[: k + 1].rstrip().endswith((".", "new ")):
                name = m.group(1)
            stack.append([name, None])
            i += 1
            continue
        if ch == ")":
            if stack:
                stack.pop()
            i += 1
            continue
        if ch == "," and stack:
            stack[-1][1] = None
            i += 1
            continue
        if ch == ":" and stack and src[i : i + 2] != "::":
            # named param at this frame's own depth? approximate: ident before
            m2 = re.search(rf"({IDENT})\s*$", src[max(0, i - 40) : i])
            if m2:
                stack[-1][1] = m2.group(1)
            i += 1
            continue
        i += 1

    for name, param in reversed(stack):
        if name is None:
            continue
        if name in ("TextSpan", "WidgetSpan", "RichText", "MarkdownBody"):
            text_span = True
        if name in ("DefaultTextStyle", "AnimatedDefaultTextStyle") and param == "style":
            default_ts_style = True
        if param in ("title", "subtitle") and name in LIST_TILE_AMBIENT:
            ambient = LIST_TILE_AMBIENT[name][param]
            break
    return ambient, text_span, default_ts_style


def pick_role(size, weight, has_color):
    """Choose (role, kwargs) for a blob with literal size/weight, no ambient."""
    if size is not None and weight is not None:
        if (size, weight) in EXACT and (
            has_color or ROLES[EXACT[(size, weight)]][2] == "heading"
        ):
            return EXACT[(size, weight)], []
        if not has_color:
            # prefer heading-coloured base so no color leaks in
            if size <= 13:
                role = "bodyMedium"
            elif size == 14:
                role = "labelLarge" if weight == "w600" else "bodyMedium"
            elif size == 15:
                role = "titleSmall"
            elif size == 16:
                role = "bodyLarge" if weight == "w400" else "titleMedium"
            elif size == 17:
                role = ("titleLarge" if weight == "w700"
                        else "titleMedium" if weight == "w600" else "bodyLarge")
            elif size == 18:
                role = "titleLarge"
            else:
                role = "headlineSmall"
        else:
            if size <= 11:
                role = "labelSmall"
            elif size == 12:
                role = "labelMedium"
            elif size == 13:
                role = "bodySmall"
            elif size == 14:
                role = "labelLarge" if weight == "w600" else "bodyMedium"
            elif size == 15:
                role = "titleSmall"
            elif size == 16:
                role = "bodyLarge" if weight == "w400" else "titleMedium"
            elif size == 17:
                role = ("titleLarge" if weight == "w700"
                        else "titleMedium" if weight == "w600" else "bodyLarge")
            elif size == 18:
                role = "titleLarge"
            else:
                role = "headlineSmall"
        rsize, rweight, _ = ROLES[role]
        kw = []
        if abs(rsize - size) > 1e-9:
            kw.append("fontSize")
        if rweight != weight:
            kw.append("fontWeight")
        return role, kw
    if weight is not None:  # no size
        role = "labelLarge" if weight == "w600" else "bodyMedium"
        kw = []
        if ROLES[role][1] != weight:
            kw.append("fontWeight")
        return role, kw
    # size present, weight absent -> ambient default is w400 (bodyMedium-ish)
    if has_color:
        if size <= 13:
            role = "bodySmall"
        elif size == 14:
            role = "bodyMedium"
        elif size <= 18:
            role = "bodyLarge"
        else:
            role = "bodyLarge"
    else:
        if size <= 13:
            role = "bodyMedium"
        elif size == 14:
            role = "bodyMedium"
        elif size <= 18:
            role = "bodyLarge"
        else:
            role = "bodyLarge"
    rsize = ROLES[role][0]
    kw = ["fontSize"] if abs(rsize - size) > 1e-9 else []
    return role, kw


def convert_blob(props, ambient):
    """Return replacement string or None to skip."""
    d = dict(props)
    names = [p[0] for p in props]
    for p in names:
        if p not in CARRY_PROPS:
            return None, "unhandled prop: " + p

    size = None
    if "fontSize" in d:
        try:
            size = float(d["fontSize"])
        except ValueError:
            return None, "non-literal fontSize"
    weight = None
    if "fontWeight" in d:
        weight = norm_weight(d["fontWeight"])
        if weight is None:
            return None, "non-literal fontWeight"
    if size is None and weight is None:
        return None, "no size/weight (color-only style)"
    has_color = "color" in d or "foreground" in d

    if ambient is not None:
        role = ambient
        rsize, rweight, _ = ROLES[role]
        # safe: role size/weight/color equal ambient; carry everything present
        kw = list(names)
        skip = set()
        if "fontSize" not in d:
            skip.add("fontSize")
        if "fontWeight" not in d:
            skip.add("fontWeight")
        if "color" not in d:
            skip.add("color")
        kw = [k for k in kw if k not in skip]
    else:
        role, auto_kw = pick_role(size, weight, has_color)
        rsize, rweight, _ = ROLES[role]
        kw = []
        for k in ["fontSize", "fontWeight", "color", "height", "letterSpacing"]:
            if k in d:
                kw.append(k)
        for k in names:
            if k in CARRY_PROPS and k not in kw and k not in (
                "fontSize", "fontWeight", "color"
            ):
                kw.append(k)
        # auto size/weight adjustments
        if "fontSize" in d and abs(rsize - size) > 1e-9 and "fontSize" not in kw:
            kw.insert(0, "fontSize")
        if weight is not None and rweight != weight and "fontWeight" not in kw:
            kw.insert(1, "fontWeight")

    # exact match short-circuit
    if not kw:
        return f"context.text.{role}", None

    parts = []
    for k in kw:
        parts.append(f"{k}: {d[k]}")
    return f"context.text.{role}?.copyWith({', '.join(parts)})", None


def process_file(path, log):
    src = open(path, encoding="utf-8").read()
    blobs = find_blobs(src)
    if not blobs:
        return False
    out = []
    last = 0
    changed = 0
    for start, end, body, is_const in blobs:
        out.append(src[last:start])
        if is_const:
            log.append(f"{path}: SKIP const TextStyle @{start}")
            out.append(src[start:end])
            last = end
            continue
        props = split_props(body)
        if props is None:
            log.append(f"{path}: SKIP positional args @{start}")
            out.append(src[start:end])
            last = end
            continue
        ambient, text_span, default_ts = ambient_scan(src, start)
        if default_ts:
            log.append(f"{path}: SKIP DefaultTextStyle.style @{start}")
            out.append(src[start:end])
            last = end
            continue
        if text_span:
            d = dict(props)
            has_w = norm_weight(d.get("fontWeight", "")) is not None
            has_c = "color" in d
            if not (has_w and has_c and "fontSize" in d):
                log.append(f"{path}: SKIP TextSpan inherit-sensitive @{start}")
                out.append(src[start:end])
                last = end
                continue
        repl, why = convert_blob(props, ambient)
        if repl is None:
            log.append(f"{path}: SKIP {why} @{start}")
            out.append(src[start:end])
            last = end
            continue
        out.append(repl)
        changed += 1
        last = end
    out.append(src[last:])
    new = "".join(out)
    if changed and IMPORT_LINE not in new and "context.text." in new:
        # insert import after last top-level import
        lines = new.split("\n")
        last_imp = -1
        for idx, ln in enumerate(lines):
            if re.match(r"^import\s+", ln):
                last_imp = idx
        if last_imp >= 0 and "app_semantic_colors.dart" not in new:
            lines.insert(last_imp + 1, IMPORT_LINE)
            new = "\n".join(lines)
    if new != src:
        open(path, "w", encoding="utf-8", newline="").write(new)
    return changed > 0


def main():
    log = []
    total_files = 0
    for root in SCOPE:
        for dp, _, fns in os.walk(root):
            for fn in sorted(fns):
                p = os.path.join(dp, fn)
                if not fn.endswith(".dart") or fn.endswith(".g.dart"):
                    continue
                if p.replace("\\", "/") in EXCLUDE:
                    continue
                if process_file(p, log):
                    total_files += 1
    print(f"files changed: {total_files}")
    with open("sweep_log.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(log))
    print(f"skips logged: {len(log)} -> sweep_log.txt")


if __name__ == "__main__":
    main()
