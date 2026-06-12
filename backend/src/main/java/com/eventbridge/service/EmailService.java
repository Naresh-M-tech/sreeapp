package com.eventbridge.service;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmailService {
    private final JavaMailSender mailSender;
    @Value("${app.frontend.url}") private String frontendUrl;

    @Async
    public void sendVerificationEmail(String to, String name, String token) {
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(to);
            msg.setSubject("Event Bridge - Verify Your Email");
            msg.setText("Hi " + name + ",\n\nPlease verify your email by clicking:\n" + frontendUrl + "/verify?token=" + token + "\n\nBest,\nEvent Bridge Team");
            mailSender.send(msg);
        } catch (Exception e) { log.warn("Email sending failed: {}", e.getMessage()); }
    }

    @Async
    public void sendPasswordResetEmail(String to, String name, String token) {
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(to);
            msg.setSubject("Event Bridge - Reset Password");
            msg.setText("Hi " + name + ",\n\nReset your password:\n" + frontendUrl + "/reset-password?token=" + token + "\n\nExpires in 1 hour.\n\nBest,\nEvent Bridge Team");
            mailSender.send(msg);
        } catch (Exception e) { log.warn("Email sending failed: {}", e.getMessage()); }
    }

    @Async
    public void sendRegistrationConfirmation(String to, String name, String eventTitle) {
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(to);
            msg.setSubject("Event Bridge - Registration Confirmed: " + eventTitle);
            msg.setText("Hi " + name + ",\n\nYou have been successfully registered for " + eventTitle + ".\n\nBest,\nEvent Bridge Team");
            mailSender.send(msg);
        } catch (Exception e) { log.warn("Email sending failed: {}", e.getMessage()); }
    }

    @Async
    public void sendEventReminder(String to, String name, String eventTitle) {
        try {
            SimpleMailMessage msg = new SimpleMailMessage();
            msg.setTo(to);
            msg.setSubject("Event Bridge - Reminder: " + eventTitle);
            msg.setText("Hi " + name + ",\n\nThis is a reminder that " + eventTitle + " is coming up soon!\n\nBest,\nEvent Bridge Team");
            mailSender.send(msg);
        } catch (Exception e) { log.warn("Email sending failed: {}", e.getMessage()); }
    }
}
