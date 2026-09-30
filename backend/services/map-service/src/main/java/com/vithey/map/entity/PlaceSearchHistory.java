package com.vithey.map.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

@Entity
@Table(name = "place_search_history")
@EntityListeners(AuditingEntityListener.class)
public class PlaceSearchHistory {

  public static final int MAX_ENTRIES_PER_USER = 20;

  @Id
  private UUID id;

  @Column(name = "user_id", nullable = false)
  private UUID userId;

  @Column(length = 100)
  private String query;

  @Column(length = 64)
  private String category;

  @Column(nullable = false)
  private double latitude;

  @Column(nullable = false)
  private double longitude;

  @Column(name = "radius_m", nullable = false)
  private int radiusM;

  @CreatedDate
  @Column(name = "created_at", nullable = false)
  private Instant createdAt;

  public PlaceSearchHistory() {
  }

  public PlaceSearchHistory(UUID userId, String query, String category, double latitude, double longitude, int radiusM) {
    this.id = UUID.randomUUID();
    this.userId = userId;
    this.query = query;
    this.category = category;
    this.latitude = latitude;
    this.longitude = longitude;
    this.radiusM = radiusM;
  }

  public UUID getId() {
    return id;
  }

  public UUID getUserId() {
    return userId;
  }

  public String getQuery() {
    return query;
  }

  public String getCategory() {
    return category;
  }

  public double getLatitude() {
    return latitude;
  }

  public double getLongitude() {
    return longitude;
  }

  public int getRadiusM() {
    return radiusM;
  }

  public Instant getCreatedAt() {
    return createdAt;
  }
}
