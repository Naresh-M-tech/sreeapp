package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;
import java.util.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "teams")
public class Team {
    @Id
    private String id;

    private String name;
    private String eventId;
    private String leaderId;
    private String leaderName;

    @Builder.Default
    private List<TeamMember> members = new ArrayList<>();

    @Builder.Default
    private List<String> inviteCodes = new ArrayList<>();

    @Builder.Default
    private TeamStatus status = TeamStatus.FORMING;

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TeamMember {
        private String userId;
        private String name;
        private String email;
        private MemberRole role;

        public enum MemberRole {
            LEADER,
            MEMBER
        }
    }

    public enum TeamStatus {
        FORMING,
        COMPLETE,
        REGISTERED,
        DISQUALIFIED
    }
}
