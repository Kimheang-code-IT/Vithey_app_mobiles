package com.vithey.notification.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import java.io.FileInputStream;
import java.io.IOException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnExpression;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.StringUtils;

@Configuration
public class FirebaseConfig {

  private static final Logger log = LoggerFactory.getLogger(FirebaseConfig.class);

  @Bean
  @ConditionalOnExpression("'${vithey.firebase.credentials-path:}'.trim().length() > 0")
  FirebaseApp firebaseApp(@Value("${vithey.firebase.credentials-path}") String credentialsPath) throws IOException {
    if (!StringUtils.hasText(credentialsPath)) {
      throw new IllegalStateException("Firebase credentials path is empty");
    }
    try (FileInputStream serviceAccount = new FileInputStream(credentialsPath)) {
      FirebaseOptions options = FirebaseOptions.builder()
          .setCredentials(GoogleCredentials.fromStream(serviceAccount))
          .build();
      if (FirebaseApp.getApps().isEmpty()) {
        log.info("Initializing Firebase app for push notifications");
        return FirebaseApp.initializeApp(options);
      }
      return FirebaseApp.getInstance();
    }
  }
}
