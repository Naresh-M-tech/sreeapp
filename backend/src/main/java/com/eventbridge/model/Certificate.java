package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "certificates")
public class Certificate {
    @Id
    private String id;

    private String userId;
    private String userName;
    private String eventId;
    private String eventTitle;
    private String registrationId;

    @Builder.Default
    private CertificateType type = CertificateType.PARTICIPATION;

    private String pdfUrl;
    private String verificationCode;

    @CreatedDate
    private Instant createdAt;

    public enum CertificateType {
        PARTICIPATION,
        WINNER,
        RUNNER_UP,
        MERIT,
        VOLUNTEER
    }
}
