package com.vithey.auth.mail;

public interface AuthMailSender {

  void sendEmailVerification(String toEmail, String rawToken);

  void sendPasswordReset(String toEmail, String rawToken);
}
