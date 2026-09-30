/// A markdown run extracted so [MarkdownBody] never layouts tables or `pre`
/// blocks (both trip `flutter_markdown`'s `_inlines.isEmpty` assertion).
class GfmChunk {
  const GfmChunk.text(this.text)
      : rows = null,
        code = null,
        language = null;
  const GfmChunk.table(this.rows)
      : text = null,
        code = null,
        language = null;
  const GfmChunk.code(this.code, [this.language])
      : text = null,
        rows = null;

  final String? text;
  final List<List<String>>? rows;
  final String? code;
  final String? language;

  bool get isTable => rows != null;
  bool get isCode => code != null;
}

/// Splits GFM pipe-tables and fenced code out of [markdown].
List<GfmChunk> splitGfmTables(String markdown) {
  if (markdown.isEmpty) return const [];

  final lines = markdown.replaceAll('\r\n', '\n').split('\n');
  final chunks = <GfmChunk>[];
  final buf = StringBuffer();
  final codeBuf = StringBuffer();
  var inFence = false;
  String? language;

  void flushText() {
    final text = buf.toString().trimRight();
    buf.clear();
    if (text.trim().isNotEmpty) chunks.add(GfmChunk.text(text));
  }

  void flushCode() {
    chunks.add(GfmChunk.code(codeBuf.toString(), language));
    codeBuf.clear();
    language = null;
  }

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trimLeft();
    if (trimmed.startsWith('```')) {
      if (!inFence) {
        flushText();
        inFence = true;
        final info = trimmed.substring(3).trim();
        language = info.isEmpty ? null : info.split(RegExp(r'\s+')).first;
      } else {
        flushCode();
        inFence = false;
      }
      continue;
    }
    if (inFence) {
      if (codeBuf.isNotEmpty) codeBuf.writeln();
      codeBuf.write(line);
      continue;
    }
    if (i + 1 < lines.length &&
        _isTableLine(line) &&
        _isSeparator(lines[i + 1])) {
      flushText();
      final rows = <List<String>>[_tableCells(line)];
      i += 2;
      while (i < lines.length &&
          _isTableLine(lines[i]) &&
          !_isSeparator(lines[i])) {
        rows.add(_tableCells(lines[i]));
        i++;
      }
      i--;
      chunks.add(GfmChunk.table(rows));
      continue;
    }
    buf.writeln(line);
  }
  if (inFence) flushCode();
  flushText();
  return chunks;
}

List<String> _tableCells(String row) {
  var inner = row.trim();
  if (inner.startsWith('|')) inner = inner.substring(1);
  if (inner.endsWith('|')) {
    inner = inner.substring(0, inner.length - 1);
  }
  if (inner.trim().isEmpty) return const [''];
  return inner.split('|').map((cell) => cell.trim()).toList();
}

/// Word-level typewriter units, except GFM pipe-tables which arrive as one
/// snapshot so the table is never streamed cell-by-cell.
List<String> tokenizeForStream(String text) {
  if (text.isEmpty) return const [];

  final normalized = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  final lines = normalized.split('\n');
  final units = <String>[];
  final buf = StringBuffer();
  var inFence = false;

  void flushWords() {
    final chunk = buf.toString();
    buf.clear();
    if (chunk.isEmpty) return;
    units.addAll(
      RegExp(r'\S+|\s+').allMatches(chunk).map((m) => m.group(0)!),
    );
  }

  var i = 0;
  while (i < lines.length) {
    final line = lines[i];
    final trimmed = line.trimLeft();

    if (trimmed.startsWith('```')) {
      inFence = !inFence;
      buf.write(line);
      if (i < lines.length - 1) buf.write('\n');
      i++;
      continue;
    }

    if (!inFence &&
        i + 1 < lines.length &&
        _isTableLine(line) &&
        _isSeparator(lines[i + 1])) {
      flushWords();
      final table = StringBuffer()
        ..write(line)
        ..write('\n')
        ..write(lines[i + 1]);
      i += 2;
      while (i < lines.length &&
          _isTableLine(lines[i]) &&
          !_isSeparator(lines[i])) {
        table
          ..write('\n')
          ..write(lines[i]);
        i++;
      }
      if (i < lines.length) table.write('\n');
      units.add(table.toString());
      continue;
    }

    buf.write(line);
    if (i < lines.length - 1) buf.write('\n');
    i++;
  }

  flushWords();
  return units;
}

bool isGfmTableStreamUnit(String unit) {
  final trimmed = unit.trimLeft();
  return trimmed.startsWith('|') && unit.contains('\n');
}

/// Makes half-typed markdown safe for [MarkdownBody] while ChatGPT-style
/// streaming is in progress (unclosed fences, tables, emphasis, links).
String stabilizeStreamingMarkdown(String raw) {
  if (raw.isEmpty) return raw;

  var text = raw.replaceAll('\r\n', '\n');
  text = _closeFencedCode(text);
  text = _closeEmphasis(text);
  text = _stripIncompleteLinks(text);
  text = _stripIncompleteHtml(text);
  text = _stabilizeLists(text);
  text = _hideIncompleteTables(text);
  return text;
}

/// Drops a trailing unfinished HTML tag (`<div`, `<br`, etc.) that can leave
/// `flutter_markdown` mid-inline and trip `_inlines.isEmpty`.
String _stripIncompleteHtml(String text) {
  return text.replaceAll(RegExp(r'<[^>\n]*$'), '');
}

/// Incomplete list markers at EOF (`- `, `* `, `1. `) confuse the builder
/// during token updates — hide the bare marker until content arrives.
String _stabilizeLists(String text) {
  return text.replaceAllMapped(
    RegExp(r'(\n|^)([ \t]*(?:[-*+]|\d+[.)])[ \t]*)$'),
    (m) => '${m[1]}',
  );
}

String _closeFencedCode(String text) {
  var inFence = false;
  for (final line in text.split('\n')) {
    if (line.trimLeft().startsWith('```')) inFence = !inFence;
  }
  if (inFence) return '$text\n```';
  return text;
}

String _closeEmphasis(String text) {
  final visible = _outsideFences(text);
  if ('**'.allMatches(visible).length.isOdd) text = '$text**';
  final singles = RegExp(r'(?<!\*)\*(?!\*)').allMatches(visible).length;
  if (singles.isOdd) text = '$text*';
  final ticks = '`'.allMatches(visible).length;
  if (ticks.isOdd) text = '$text`';
  return text;
}

String _outsideFences(String text) {
  final out = StringBuffer();
  var inFence = false;
  for (final line in text.split('\n')) {
    if (line.trimLeft().startsWith('```')) {
      inFence = !inFence;
      continue;
    }
    if (!inFence) out.writeln(line);
  }
  return out.toString();
}

String _stripIncompleteLinks(String text) {
  return text
      .replaceAll(RegExp(r'\[[^\]]*$'), '')
      .replaceAll(RegExp(r'\[[^\]]*\]\([^)]*$'), '');
}

/// Tables are not streamed: hide a trailing pipe-table until it is complete
/// (header + separator, every row closed).
String _hideIncompleteTables(String text) {
  final lines = text.split('\n');
  var end = lines.length - 1;
  while (end >= 0 && lines[end].trim().isEmpty) {
    end--;
  }
  if (end < 0 || !_isTableLine(lines[end])) return text;

  var start = end;
  while (start > 0 && _isTableLine(lines[start - 1])) {
    start--;
  }

  final table = lines.sublist(start, end + 1);
  if (_isCompleteTable(table)) return text;

  final kept = [...lines.sublist(0, start)];
  while (kept.isNotEmpty && kept.last.trim().isEmpty) {
    kept.removeLast();
  }
  return kept.join('\n');
}

bool _isCompleteTable(List<String> table) {
  if (table.length < 2) return false;
  if (!_isTableLine(table[0]) || !_isSeparator(table[1])) return false;
  for (var i = 0; i < table.length; i++) {
    if (i == 1) continue;
    final row = table[i].trimRight();
    if (!_isTableLine(row) || _isSeparator(row)) return false;
    if (!row.endsWith('|')) return false;
  }
  return true;
}

bool _isTableLine(String line) => line.trimLeft().startsWith('|');

bool _isSeparator(String line) {
  final t = line.trim();
  return RegExp(r'^\|?(\s*:?-{2,}:?\s*\|)+\s*:?-{2,}:?\s*\|?\s*$').hasMatch(t);
}
