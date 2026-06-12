package com.eventbridge.model;

import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.Instant;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "messages")
public class Message {
    @Id
    private String id;

    private String chatRoomId;
    private String senderId;
    private String senderName;
    private String content;

    @Builder.Default
    private MessageType type = MessageType.TEXT;

    private String attachmentUrl;

    @CreatedDate
    private Instant createdAt;

    public enum MessageType {
        TEXT,
        IMAGE,
        FILE,
        SYSTEM
    }
}
