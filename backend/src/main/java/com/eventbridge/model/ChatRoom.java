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
@Document(collection = "chat_rooms")
public class ChatRoom {
    @Id
    private String id;

    private String name;

    @Builder.Default
    private ChatRoomType type = ChatRoomType.EVENT;

    private String eventId;

    @Builder.Default
    private List<String> participantIds = new ArrayList<>();

    @CreatedDate
    private Instant createdAt;

    @LastModifiedDate
    private Instant updatedAt;

    public enum ChatRoomType {
        EVENT,
        DIRECT,
        GROUP
    }
}
