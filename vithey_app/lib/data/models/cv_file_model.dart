class LocalCvFile {
  const LocalCvFile({
    required this.path,
    required this.displayName,
    required this.sizeBytes,
    required this.mimeType,
  });

  final String path;
  final String displayName;
  final int sizeBytes;
  final String mimeType;

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class UploadedCvFile {
  const UploadedCvFile({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String fileId;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
}
