package com.vithey.profile.entity;

public final class FieldVisibility {

  public static final String PUBLIC = "PUBLIC";
  public static final String PRIVATE = "PRIVATE";
  public static final String OWNER_ONLY = "OWNER_ONLY";

  private FieldVisibility() {
  }

  public static boolean isPublic(String visibility) {
    return PUBLIC.equalsIgnoreCase(visibility);
  }
}
