package com.vithey.auth.mail;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

/**
 * Local/dev delivery: logs opaque tokens so verify/reset can be exercised without SMTP.
 * Excluded from the {@code prod} profile so tokens are never logged in production
 * (prod must configure {@code vithey.mail.mode=smtp}).
 */
@Component
@Profile("!prod")
@ConditionalOnProperty(name = "vithey.mail.mode", havingValue = "log", matchIfMissing = true)
public class LoggingAuthMailSender implements AuthMailSender {

  private static final Logger log = LoggerFactory.getLogger(LoggingAuthMailSender.class);

  @Override
  public void sendEmailVerification(String toEmail, String rawToken) {
    log.info("AUTH_MAIL mode=log type=email_verification to={} token={}", toEmail, rawToken);
  }

  @Override
  public void sendPasswordReset(String toEmail, String rawToken) {
    log.info("AUTH_MAIL mode=log type=password_reset to={} token={}", toEmail, rawToken);
  }
}
