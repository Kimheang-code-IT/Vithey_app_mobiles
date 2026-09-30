package com.vithey.auth.mail;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "vithey.mail.mode", havingValue = "smtp")
public class SmtpAuthMailSender implements AuthMailSender {

  private static final Logger log = LoggerFactory.getLogger(SmtpAuthMailSender.class);

  private final JavaMailSender mailSender;
  private final String fromAddress;

  public SmtpAuthMailSender(
      JavaMailSender mailSender,
      @Value("${vithey.mail.from:noreply@vithey.local}") String fromAddress
  ) {
    this.mailSender = mailSender;
    this.fromAddress = fromAddress;
  }

  @Override
  public void sendEmailVerification(String toEmail, String rawToken) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(fromAddress);
    message.setTo(toEmail);
    message.setSubject("Verify your Vithey email");
    message.setText(
        """
        Use this token to verify your email via POST /api/v1/auth/verify-email:

        %s

        The token expires in 24 hours.
        """.formatted(rawToken)
    );
    mailSender.send(message);
    log.info("AUTH_MAIL mode=smtp type=email_verification to={}", toEmail);
  }

  @Override
  public void sendPasswordReset(String toEmail, String rawToken) {
    SimpleMailMessage message = new SimpleMailMessage();
    message.setFrom(fromAddress);
    message.setTo(toEmail);
    message.setSubject("Reset your Vithey password");
    message.setText(
        """
        Use this token to reset your password via POST /api/v1/auth/reset-password:

        %s

        The token expires in 30 minutes. If you did not request this, ignore this email.
        """.formatted(rawToken)
    );
    mailSender.send(message);
    log.info("AUTH_MAIL mode=smtp type=password_reset to={}", toEmail);
  }
}
