package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "announcements")
public class Announcement {
    @Id
    private String id;

    private String title;
    private String content;
    private String eventId;
    private String createdBy;
    private String createdByName;

    @Builder.Default
    private AnnouncementType type = AnnouncementType.GLOBAL;

    @Builder.Default
    private boolean published = true;

    private Instant scheduledAt;

    @Builder.Default
    private Priority priority = Priority.NORMAL;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    public enum AnnouncementType {
        GLOBAL,
        EVENT_SPECIFIC,
        DEPARTMENT
    }

    public enum Priority {
        LOW,
        NORMAL,
        HIGH,
        URGENT
    }
}
