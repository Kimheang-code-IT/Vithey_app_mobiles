package com.vithey.profile.repository;

import com.vithey.profile.entity.Profile;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ProfileRepository extends JpaRepository<Profile, UUID> {

  @Query("""
      SELECT profile.userId AS userId,
             profile.fullName AS fullName,
             profile.avatarUrl AS avatarUrl,
             profile.university AS university,
             profile.major AS major,
             profile.workplace AS workplace
      FROM Profile profile
      WHERE LOWER(profile.fullName) LIKE LOWER(CONCAT('%', :search, '%')) ESCAPE '\\'
         OR LOWER(profile.university) LIKE LOWER(CONCAT('%', :search, '%')) ESCAPE '\\'
         OR LOWER(profile.major) LIKE LOWER(CONCAT('%', :search, '%')) ESCAPE '\\'
      ORDER BY profile.fullName ASC
      """)
  Page<UserSearchProjection> searchByFullName(@Param("search") String search, Pageable pageable);
}