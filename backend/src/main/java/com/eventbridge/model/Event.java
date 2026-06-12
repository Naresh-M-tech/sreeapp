package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import jakarta.validation.constraints.*;
import java.time.Instant;
import java.time.LocalDateTime;
import java.util.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "events")
public class Event {
    @Id
    private String id;

    @NotBlank
    private String title;

    @NotBlank
    private String description;

    @NotNull
    private EventCategory category;

    private String venue;
    private LocalDateTime startDate;
    private LocalDateTime endDate;
    private LocalDateTime registrationDeadline;

    @Indexed
    private String organizerId;
    private String organizerName;

    @Builder.Default
    private int capacity = 0;

    @Builder.Default
    private int registeredCount = 0;

    private String bannerImageUrl;

    @Builder.Default
    private List<String> rules = new ArrayList<>();

    private String eligibility;

    @Builder.Default
    private double registrationFee = 0.0;

    private ContactInfo contactInfo;
    
    @Builder.Default
    private boolean teamEvent = false;

    @Builder.Default
    private int minTeamSize = 1;

    @Builder.Default
    private int maxTeamSize = 1;

    @Builder.Default
    private EventStatus status = EventStatus.DRAFT;

    @Builder.Default
    private List<String> tags = new ArrayList<>();

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    public enum EventCategory {
        TECHNICAL,
        NON_TECHNICAL,
        WORKSHOP,
        HACKATHON,
        SEMINAR,
        CULTURAL,
        SPORTS
    }

    public enum EventStatus {
        DRAFT,
        PENDING_APPROVAL,
        APPROVED,
        PUBLISHED,
        ONGOING,
        COMPLETED,
        CANCELLED
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ContactInfo {
        private String name;
        private String email;
        private String phone;
    }
}
