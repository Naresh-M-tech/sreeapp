package com.eventbridge.dto;

import com.eventbridge.model.Event;
import jakarta.validation.constraints.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.List;

public class EventDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateRequest {
        @NotBlank(message = "Title is required")
        private String title;

        @NotBlank(message = "Description is required")
        private String description;

        @NotNull(message = "Category is required")
        private Event.EventCategory category;

        private String venue;
        private LocalDateTime startDate;
        private LocalDateTime endDate;
        private LocalDateTime registrationDeadline;
        private int capacity;
        private String bannerImageUrl;
        private List<String> rules;
        private String eligibility;
        private double registrationFee;
        private Event.ContactInfo contactInfo;
        private boolean teamEvent;
        private int minTeamSize;
        private int maxTeamSize;
        private List<String> tags;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UpdateRequest {
        private String title;
        private String description;
        private Event.EventCategory category;
        private String venue;
        private LocalDateTime startDate;
        private LocalDateTime endDate;
        private LocalDateTime registrationDeadline;
        private int capacity;
        private String bannerImageUrl;
        private List<String> rules;
        private String eligibility;
        private double registrationFee;
        private Event.ContactInfo contactInfo;
        private boolean teamEvent;
        private int minTeamSize;
        private int maxTeamSize;
        private List<String> tags;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class EventResponse {
        private String id;
        private String title;
        private String description;
        private Event.EventCategory category;
        private String venue;
        private LocalDateTime startDate;
        private LocalDateTime endDate;
        private LocalDateTime registrationDeadline;
        private String organizerId;
        private String organizerName;
        private int capacity;
        private int registeredCount;
        private String bannerImageUrl;
        private List<String> rules;
        private String eligibility;
        private double registrationFee;
        private Event.ContactInfo contactInfo;
        private boolean teamEvent;
        private int minTeamSize;
        private int maxTeamSize;
        private Event.EventStatus status;
        private List<String> tags;
        private String createdAt;
        private String updatedAt;
        private boolean isRegistered;
    }
}
