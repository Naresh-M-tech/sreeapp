package com.eventbridge.dto;

import lombok.*;

import java.time.LocalDate;
import java.util.List;

public class ChatDto {

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class ChatMessage {
        private String chatRoomId;
        private String senderId;
        private String senderName;
        private String content;
        private String type;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TypingIndicator {
        private String chatRoomId;
        private String userId;
        private String userName;
        private boolean typing;
    }

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class CreateChatRoomRequest {
        private String name;
        private String type;
        private String eventId;
        private List<String> participantIds;
    }
}

