package com.vithey.map;

import static org.assertj.core.api.Assertions.assertThat;

import com.vithey.map.dto.request.NearbySearchRequest;
import com.vithey.map.dto.request.TextSearchRequest;
import org.junit.jupiter.api.Test;
import org.springframework.beans.MutablePropertyValues;
import org.springframework.validation.DataBinder;

class PlaceQueryParameterBindingTest {

  @Test
  void nearbyBindsDocumentedSnakeCaseQueryParameters() {
    NearbySearchRequest request = new NearbySearchRequest();
    DataBinder binder = new DataBinder(request);
    MutablePropertyValues values = new MutablePropertyValues();
    values.add("lat", 11.5564);
    values.add("lng", 104.9282);
    values.add("radius_m", 2000);
    values.add("category", "cafe");
    values.add("open_now", true);
    values.add("min_rating", 4.0);
    values.add("price_level", 2);
    values.add("page_token", "tok-1");
    values.add("limit", 10);
    binder.bind(values);

    assertThat(binder.getBindingResult().hasErrors()).isFalse();
    assertThat(request.getLat()).isEqualTo(11.5564);
    assertThat(request.getLng()).isEqualTo(104.9282);
    assertThat(request.getRadiusM()).isEqualTo(2000);
    assertThat(request.getCategory()).isEqualTo("cafe");
    assertThat(request.getOpenNow()).isTrue();
    assertThat(request.getMinRating()).isEqualTo(4.0);
    assertThat(request.getPriceLevel()).isEqualTo(2);
    assertThat(request.getPageToken()).isEqualTo("tok-1");
    assertThat(request.getLimit()).isEqualTo(10);
  }

  @Test
  void searchBindsDocumentedSnakeCaseQueryParameters() {
    TextSearchRequest request = new TextSearchRequest();
    DataBinder binder = new DataBinder(request);
    MutablePropertyValues values = new MutablePropertyValues();
    values.add("query", "coffee");
    values.add("lat", 11.5564);
    values.add("lng", 104.9282);
    values.add("radius_m", 3000);
    values.add("open_now", false);
    values.add("min_rating", 3.5);
    values.add("price_level", 1);
    values.add("page_token", "tok-2");
    binder.bind(values);

    assertThat(binder.getBindingResult().hasErrors()).isFalse();
    assertThat(request.getQuery()).isEqualTo("coffee");
    assertThat(request.getRadiusM()).isEqualTo(3000);
    assertThat(request.getOpenNow()).isFalse();
    assertThat(request.getMinRating()).isEqualTo(3.5);
    assertThat(request.getPriceLevel()).isEqualTo(1);
    assertThat(request.getPageToken()).isEqualTo("tok-2");
  }
}
