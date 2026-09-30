package com.vithey.notification.repository;

import com.vithey.notification.entity.Notification;
import java.time.OffsetDateTime;
import java.util.UUID;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface NotificationRepository extends JpaRepository<Notification, UUID> {

  @Query("SELECT n FROM Notification n WHERE n.userId = :userId "
      + "AND (:isRead IS NULL OR n.read = :isRead) ORDER BY n.createdAt DESC")
  Page<Notification> findByUserIdFilteringRead(
      @Param("userId") UUID userId,
      @Param("isRead") Boolean isRead,
      Pageable pageable);

  long countByUserIdAndReadFalse(UUID userId);

  boolean existsByUserIdAndDedupeKey(UUID userId, String dedupeKey);

  @Modifying
  @Query("UPDATE Notification n SET n.read = true, n.readAt = :now "
      + "WHERE n.userId = :userId AND n.read = false")
  int markAllRead(@Param("userId") UUID userId, @Param("now") OffsetDateTime now);
}
