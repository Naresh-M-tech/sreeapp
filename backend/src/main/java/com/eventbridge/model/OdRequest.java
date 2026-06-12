package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "od_requests")
public class OdRequest {
    @Id
    private String id;

    private String studentId;
    private String studentName;
    private String studentEmail;
    private String studentRollNumber;
    private String department;

    private String eventId;
    private String eventTitle;

    private LocalDate fromDate;
    private LocalDate toDate;
    private String reason;

    private String facultyId;
    private String facultyName;

    @Builder.Default
    private OdStatus status = OdStatus.PENDING;

    private String remarks;
    private String pdfUrl;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    public enum OdStatus {
        PENDING,
        APPROVED,
        REJECTED,
        CANCELLED
    }
}
