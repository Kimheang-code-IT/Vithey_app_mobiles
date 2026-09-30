import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class CreatePostMediaZone extends StatelessWidget {
  const CreatePostMediaZone({
    super.key,
    required this.mediaPath,
    required this.isVideo,
    required this.isUploading,
    required this.onPick,
    required this.onClear,
  });

  final String? mediaPath;
  final bool isVideo;
  final bool isUploading;
  final VoidCallback onPick;
  final VoidCallback onClear;

  bool get _isRemote =>
      mediaPath?.startsWith('http://') == true ||
      mediaPath?.startsWith('https://') == true;

  bool get _isAsset => mediaPath?.startsWith('assets/') == true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : onPick,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.appColors.inputFill,
        ),
        child: mediaPath == null || mediaPath!.isEmpty
            ? SizedBox(
                height: 120,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VitheyIcon(
                      LucideIcons.imagePlus,
                      size: 36,
                      color: context.appColors.muted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add photo or video',
                      style: TextStyle(color: context.appColors.muted),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  if (isVideo)
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: ColoredBox(
                        color: Colors.black87,
                        child: Center(
                          child: VitheyIcon(
                            LucideIcons.video,
                            size: 48,
                            color: context.scheme.onPrimary,
                          ),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 440),
                      child: _buildImage(context),
                    ),
                  if (isUploading)
                    const Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black45,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          shape: const CircleBorder(),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const VitheyIcon(
                          LucideIcons.x,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: isUploading ? null : onClear,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final path = mediaPath!;
    final error = SizedBox(
      height: 180,
      width: double.infinity,
      child: Center(
        child: VitheyIcon(
          LucideIcons.imageOff,
          color: context.appColors.muted,
        ),
      ),
    );

    if (_isRemote) {
      return Image.network(
        path,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => error,
      );
    }
    if (_isAsset) {
      return Image.asset(
        path,
        width: double.infinity,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => error,
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => error,
    );
  }
}
