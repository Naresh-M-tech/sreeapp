package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "registrations")
public class Registration {
    @Id
    private String id;

    private String userId;
    private String userName;
    private String userEmail;
    private String eventId;
    private String eventTitle;
    private String teamId;

    @Builder.Default
    private RegistrationStatus status = RegistrationStatus.REGISTERED;

    @Builder.Default
    private boolean attended = false;

    private String certificateUrl;
    private String transactionId;
    private double amountPaid;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    public enum RegistrationStatus {
        REGISTERED,
        CONFIRMED,
        WAITLISTED,
        CANCELLED,
        ATTENDED
    }
}
