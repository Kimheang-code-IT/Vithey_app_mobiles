import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Avatar with network image and initials fallback.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 24,
    this.backgroundColor,
  });

  final String? imageUrl;
  final String? name;
  final double radius;

  /// Fill behind the image / initials. Defaults to primaryContainer.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(name);
    final fill = backgroundColor ??
        Theme.of(context).colorScheme.primaryContainer;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      final ImageProvider<Object> provider = imageUrl!.startsWith('http')
          ? CachedNetworkImageProvider(imageUrl!)
          : FileImage(File(imageUrl!)) as ImageProvider<Object>;
      return CircleAvatar(
        radius: radius,
        backgroundColor: fill,
        backgroundImage: provider,
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: fill,
      child: Text(initials, style: TextStyle(fontSize: radius * 0.45)),
    );
  }

  String _initials(String? value) {
    if (value == null || value.trim().isEmpty) return '?';
    final parts = value.trim().split(' ');
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
