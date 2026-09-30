package com.vithey.map.filter;

import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * Vithey place categories mapped to Google Places API (New) types.
 */
public enum PlaceCategory {
  RESTAURANT("restaurant", List.of("restaurant")),
  CAFE("cafe", List.of("cafe", "coffee_shop")),
  CONVENIENCE_STORE("convenience_store", List.of("convenience_store")),
  SUPERMARKET("supermarket", List.of("supermarket", "grocery_store")),
  PHARMACY("pharmacy", List.of("pharmacy")),
  ATM("atm", List.of("atm")),
  BANK("bank", List.of("bank")),
  GAS_STATION("gas_station", List.of("gas_station")),
  SHOPPING_MALL("shopping_mall", List.of("shopping_mall")),
  LODGING("lodging", List.of("lodging")),
  HOSPITAL("hospital", List.of("hospital")),
  UNIVERSITY("university", List.of("university")),
  OTHER("other", List.of());

  private final String value;
  private final List<String> googleTypes;

  PlaceCategory(String value, List<String> googleTypes) {
    this.value = value;
    this.googleTypes = googleTypes;
  }

  public String value() {
    return value;
  }

  public List<String> googleTypes() {
    return googleTypes;
  }

  public boolean hasTypeFilter() {
    return !googleTypes.isEmpty();
  }

  public static PlaceCategory fromValue(String raw) {
    if (raw == null || raw.isBlank()) {
      return null;
    }
    String normalized = raw.trim().toLowerCase(Locale.ROOT);
    return Arrays.stream(values())
        .filter(category -> category.value.equals(normalized))
        .findFirst()
        .orElseThrow(() -> new IllegalArgumentException(
            "Unknown category: " + raw + ". Allowed: " + Arrays.stream(values())
                .map(PlaceCategory::value)
                .reduce((a, b) -> a + ", " + b)
                .orElse("")));
  }

  /** Reverse mapping from a Google primary type to a Vithey category value. */
  public static String fromGoogleType(String primaryType) {
    if (primaryType == null || primaryType.isBlank()) {
      return OTHER.value;
    }
    String normalized = primaryType.trim().toLowerCase(Locale.ROOT);
    return Arrays.stream(values())
        .filter(category -> category.googleTypes.contains(normalized))
        .map(PlaceCategory::value)
        .findFirst()
        .orElse(OTHER.value);
  }
}
