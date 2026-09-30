package com.vithey.profile.repository;

import java.util.UUID;

public interface UserSearchProjection {

  UUID getUserId();

  String getFullName();

  String getAvatarUrl();

  String getUniversity();

  String getMajor();

  String getWorkplace();
}