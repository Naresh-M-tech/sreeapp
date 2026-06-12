package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "audit_logs")
public class AuditLog {
    @Id
    private String id;

    private String userId;
    private String userName;
    private String action;
    private String entityType;
    private String entityId;
    private String details;
    private String ipAddress;

    @CreatedDate
    private Instant createdAt;
}
