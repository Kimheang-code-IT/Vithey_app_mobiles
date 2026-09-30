package com.vithey.map.config;

import io.netty.channel.ChannelOption;
import java.time.Duration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.reactive.ReactorClientHttpConnector;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.netty.http.client.HttpClient;

/**
 * WebClient pointed at Google Places API (New). The API key is attached as a
 * default header and must never appear in logs or error payloads.
 */
@Configuration
public class GooglePlacesConfig {

  @Bean
  public WebClient googlePlacesWebClient(GooglePlacesProperties properties) {
    HttpClient httpClient = HttpClient.create()
        .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, (int) properties.connectTimeoutMs())
        .responseTimeout(Duration.ofMillis(properties.responseTimeoutMs()));

    return WebClient.builder()
        .baseUrl(properties.baseUrl())
        .defaultHeader("X-Goog-Api-Key", properties.apiKey() == null ? "" : properties.apiKey())
        .clientConnector(new ReactorClientHttpConnector(httpClient))
        .build();
  }
}
