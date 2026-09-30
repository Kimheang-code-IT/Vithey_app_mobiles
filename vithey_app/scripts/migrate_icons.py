# -*- coding: utf-8 -*-
"""One-pass Material Icons -> Lucide migration for Vithey."""
import re, os, io

ROOTS = [
    "lib/modules",
    "lib/core/widgets",
    "lib/core/alerts",
    "lib/data/models",
]
BARREL = "package:aub_connect_app/core/icons/vithey_icons.dart"

# Material base name -> Lucide name (suffix variants resolved by stripping)
M = {
    "arrow_back": "arrowLeft", "arrow_back_ios": "arrowLeft",
    "arrow_forward": "chevronRight", "chevron_right": "chevronRight",
    "chevron_left": "chevronLeft", "arrow_upward": "arrowUp",
    "arrow_downward": "arrowDown", "arrow_drop_down": "chevronDown",
    "keyboard_arrow_down": "chevronDown", "keyboard_arrow_up": "chevronUp",
    "search": "search", "search_off": "searchX", "map": "map",
    "chat_bubble": "messageCircle", "chat": "messageCircle",
    "wallet": "wallet", "account_balance_wallet": "wallet",
    "account_balance": "landmark", "payments": "creditCard", "credit_card": "creditCard",
    "receipt": "receipt",
    "close": "x", "clear": "x", "cancel": "circleX",
    "check": "check", "check_circle": "circleCheck", "done": "check", "done_all": "checkCheck",
    "add": "plus", "add_circle": "circlePlus", "add_photo_alternate": "imagePlus",
    "add_location_alt": "mapPinPlus", "remove": "minus", "delete": "trash2",
    "edit": "pencil", "edit_note": "penLine",
    "more_vert": "ellipsisVertical", "more_horiz": "ellipsis",
    "settings": "settings",
    "person": "user", "person_add": "userPlus", "people": "users",
    "group": "users", "groups": "users",
    "home": "house", "notifications": "bell", "notifications_none": "bell",
    "notifications_off": "bellOff",
    "favorite": "heart", "share": "share2", "ios_share": "share", "send": "send",
    "image": "image", "photo": "image", "photo_library": "images",
    "broken_image": "imageOff", "image_not_supported": "imageOff",
    "picture_as_pdf": "fileText", "insert_drive_file": "fileText",
    "description": "fileText", "article": "fileText", "notes": "fileText",
    "videocam": "video", "video_collection": "video", "videocam_off": "videoOff",
    "camera_alt": "camera", "photo_camera": "camera", "flip_camera_ios": "switchCamera",
    "mic": "mic", "mic_none": "mic", "mic_off": "micOff", "record_voice_over": "mic",
    "attach_file": "paperclip", "link": "link",
    "lock": "lock", "vpn_key": "keyRound", "fingerprint": "fingerprint",
    "visibility": "eye", "remove_red_eye": "eye", "visibility_off": "eyeOff",
    "email": "mail", "mail": "mail", "mark_email_unread": "mail", "mark_email_read": "mailCheck",
    "phone": "phone", "call": "phone", "call_end": "phoneOff", "phone_iphone": "smartphone",
    "smartphone": "smartphone",
    "location_on": "mapPin", "place": "mapPin", "location_pin": "mapPin",
    "my_location": "locate", "gps_not_fixed": "locateFixed",
    "directions": "navigation", "navigation": "navigation",
    "work": "briefcase", "work_outline": "briefcase", "apartment": "building2",
    "storefront": "store", "school": "graduationCap",
    "menu_book": "bookOpen", "auto_stories": "bookOpen", "history_edu": "history",
    "info": "info", "info_outline": "info", "warning": "triangleAlert",
    "error": "circleAlert", "error_outline": "circleAlert",
    "help": "circleHelp", "help_outline": "circleHelp",
    "refresh": "refreshCw", "filter_list": "listFilter", "filter_list_off": "listX",
    "sort": "arrowUpDown", "tune": "slidersHorizontal",
    "calendar_today": "calendar", "event": "calendar", "event_available": "calendarCheck",
    "access_time": "clock", "schedule": "clock",
    "star": "star", "star_border": "star", "star_outline": "star",
    "bookmark": "bookmark", "content_copy": "copy", "copy": "copy",
    "download": "download", "upload": "upload",
    "play_arrow": "play", "play_circle": "circlePlay", "pause": "pause",
    "pause_circle": "circlePause", "stop": "square",
    "replay_10": "rotateCcw", "forward_10": "rotateCw",
    "volume_up": "volume2", "volume_off": "volumeX", "fullscreen": "maximize",
    "logout": "logOut", "login": "logIn",
    "language": "languages", "translate": "languages",
    "dark_mode": "moon", "light_mode": "sun", "menu": "menu",
    "dashboard": "layoutDashboard", "grid_view": "layoutGrid",
    "qr_code": "qrCode", "qr_code_2": "qrCode", "qr_code_scanner": "scanLine",
    "verified": "badgeCheck", "verified_user": "shieldCheck", "badge": "badge",
    "auto_awesome": "sparkles", "smart_toy": "bot", "code": "code", "data_object": "braces",
    "terminal": "terminal", "folder": "folder",
    "thumb_up": "thumbsUp", "thumb_up_alt": "thumbsUp",
    "thumb_down": "thumbsDown", "thumb_down_alt": "thumbsDown",
    "reply": "reply", "block": "ban", "report": "flag", "flag": "flag",
    "layers": "layers", "history": "history", "shield": "shield", "security": "shield",
    "trending_up": "trendingUp", "insights": "chartLine", "analytics": "chartLine",
    "psychology": "brain", "tips_and_updates": "lightbulb", "lightbulb": "lightbulb",
    "public": "globe", "web": "globe", "wifi": "wifi",
    "workspace_premium": "award", "sports_soccer": "volleyball", "sports_esports": "gamepad2",
    "pets": "pawPrint", "restaurant": "utensils", "flight": "plane",
    "fitness_center": "dumbbell", "music_note": "music", "palette": "palette",
    "brush": "brush", "design_services": "penTool", "colorize": "pipette",
    "architecture": "pencilRuler", "handyman": "wrench", "build": "wrench",
    "account_tree": "network", "memory": "cpu", "storage": "database", "dns": "server",
    "extension": "puzzle", "science": "flaskConical", "biotech": "microscope",
    "cake": "cake", "casino": "dices", "diamond": "gem", "handshake": "handshake",
    "emoji_emotions": "smile", "mode_comment": "messageSquare", "inbox": "inbox",
    "campaign": "megaphone", "rocket_launch": "rocket", "view_in_ar": "box",
    "laptop_mac": "laptop", "desktop_windows": "monitor", "keyboard": "keyboard",
    "cloud": "cloud", "bolt": "zap", "flashlight_on": "flashlight",
    "swap_horiz": "arrowLeftRight", "open_in_new": "externalLink", "facebook": "facebook",
    "radio_button_checked": "circleDot", "radio_button_off": "circle",
    "radio_button_unchecked": "circle", "circle": "circle", "push_pin": "pin",
    "repeat": "repeat",
    "person_add_alt_1": "userPlus",
    "play_circle_fill": "circlePlay",
    "track_changes": "crosshair",
}

SUFFIXES = ["_outlined_rounded", "_outlined", "_rounded", "_outline", "_border"]

def resolve(name):
    n = name
    while n:
        if n in M:
            return M[n]
        for s in SUFFIXES:
            if n.endswith(s):
                n = n[: -len(s)]
                break
        else:
            return None
    return None

icon_re = re.compile(r"\bIcons\.([a-zA-Z0-9_]+)")
import_line = "import '%s';\n" % BARREL
import_re = re.compile(r"import\s+[^;]+;\s*\n", re.M)
last_import_re = None

changed_files = 0
swaps = {}
unresolved = {}

for root in ROOTS:
    for dirpath, _, files in os.walk(root):
        for fn in files:
            if not fn.endswith(".dart"):
                continue
            path = os.path.join(dirpath, fn)
            with io.open(path, encoding="utf-8") as f:
                src = f.read()
            orig = src

            def sub(m):
                nm = m.group(1)
                if nm == "messageCircle":  # already-lucide name mis-prefixed
                    swaps[nm] = swaps.get(nm, 0) + 1
                    return "LucideIcons.messageCircle"
                tgt = resolve(nm)
                if tgt is None:
                    unresolved.setdefault(nm, []).append(path)
                    return m.group(0)
                key = "%s -> %s" % (nm, tgt)
                swaps[key] = swaps.get(key, 0) + 1
                return "LucideIcons." + tgt

            if "Icons." in src:
                src = icon_re.sub(sub, src)

            if src == orig:
                continue

            # ensure barrel import (unless widgets.dart kit is already imported)
            has_barrel = BARREL in src
            has_kit = "core/widgets/widgets.dart" in src
            if not has_barrel and not has_kit:
                ends = list(import_re.finditer(src))
                pos = ends[-1].end() if ends else 0
                src = src[:pos] + import_line + src[pos:]

            with io.open(path, "w", encoding="utf-8", newline="") as f:
                f.write(src)
            changed_files += 1

print("changed files:", changed_files)
print("\n-- unresolved Material icons --")
for k, v in sorted(unresolved.items()):
    print(k, "->", v[:3])
print("\n-- top swaps --")
for k, v in sorted(swaps.items(), key=lambda x: -x[1])[:40]:
    print(v, k)
print("total swaps:", sum(swaps.values()))
