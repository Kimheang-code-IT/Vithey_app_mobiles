import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';

class SearchHighlightText extends StatelessWidget {
  const SearchHighlightText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final q = query.trim().toLowerCase();
    if (q.length < 2) {
      return Text(text,
          style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final lower = text.toLowerCase();
    final index = lower.indexOf(q);
    if (index < 0) {
      return Text(text,
          style: style, maxLines: maxLines, overflow: TextOverflow.ellipsis);
    }

    final before = text.substring(0, index);
    final match = text.substring(index, index + q.length);
    final after = text.substring(index + q.length);

    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: style.copyWith(fontWeight: VitheyWeight.bold),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}
