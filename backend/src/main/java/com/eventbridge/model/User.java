package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.index.Indexed;
import org.springframework.data.mongodb.core.mapping.Document;

import jakarta.validation.constraints.*;
import java.time.Instant;
import java.util.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "users")
public class User {
    @Id
    private String id;

    @NotBlank
    @Size(min = 3, max = 50)
    private String name;

    @NotBlank
    @Email
    @Indexed(unique = true)
    private String email;

    @NotBlank
    private String password;

    @Size(max = 15)
    private String phone;

    private String department;
    private String college;
    private String rollNumber;
    private String profileImageUrl;
    private String bio;

    @Builder.Default
    private Set<Role> roles = new HashSet<>();

    @Builder.Default
    private boolean enabled = false;

    @Builder.Default
    private boolean emailVerified = false;

    private String emailVerificationToken;
    private Instant emailVerificationExpiry;
    private String passwordResetToken;
    private Instant passwordResetExpiry;

    @Builder.Default
    private boolean online = false;

    private Instant lastSeen;
    private String refreshToken;
    private Instant refreshTokenExpiry;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    public enum Role {
        ROLE_ADMIN,
        ROLE_ORGANIZER,
        ROLE_FACULTY,
        ROLE_PARTICIPANT
    }
}
