package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "notifications")
public class Notification {
    @Id
    private String id;

    private String userId;
    private String title;
    private String message;

    @Builder.Default
    private NotificationType type = NotificationType.GENERAL;

    private String referenceId;
    private String referenceType;

    @Builder.Default
    private boolean read = false;

    @CreatedDate
    private Instant createdAt;

    public enum NotificationType {
        GENERAL,
        EVENT,
        REGISTRATION,
        OD_REQUEST,
        TEAM,
        CHAT,
        ANNOUNCEMENT,
        SYSTEM
    }
}
