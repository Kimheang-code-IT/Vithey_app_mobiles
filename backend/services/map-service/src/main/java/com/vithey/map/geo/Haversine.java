package com.vithey.map.geo;

import java.lang.Math;

/** Great-circle distance helpers. */
public final class Haversine {

  private static final double EARTH_RADIUS_M = 6371000.0;

  private Haversine() {
  }

  /** Distance in meters between two WGS84 points, rounded to whole meters. */
  public static long meters(double lat1, double lng1, double lat2, double lng2) {
    double dLat = Math.toRadians(lat2 - lat1);
    double dLng = Math.toRadians(lng2 - lng1);
    double a = Math.pow(Math.sin(dLat / 2), 2)
        + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) * Math.pow(Math.sin(dLng / 2), 2);
    double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(EARTH_RADIUS_M * c);
  }
}
