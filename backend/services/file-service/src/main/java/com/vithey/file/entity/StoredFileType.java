package com.vithey.file.entity;

public enum StoredFileType {
  AVATAR("avatars", 10L * 1024 * 1024),
  CV("cvs", 10L * 1024 * 1024),
  POSTER("posters", 10L * 1024 * 1024),
  VIDEO("videos", 50L * 1024 * 1024),
  CHAT_ATTACHMENT("chat-attachments", 10L * 1024 * 1024);

  private final String bucket;
  private final long maxSizeBytes;

  StoredFileType(String bucket, long maxSizeBytes) {
    this.bucket = bucket;
    this.maxSizeBytes = maxSizeBytes;
  }

  public String bucket() {
    return bucket;
  }

  public long maxSizeBytes() {
    return maxSizeBytes;
  }
}
