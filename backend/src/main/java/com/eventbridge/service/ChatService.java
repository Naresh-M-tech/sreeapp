package com.eventbridge.service;

import com.eventbridge.dto.ChatDto;
import com.eventbridge.model.*;
import com.eventbridge.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatRoomRepository chatRoomRepository;
    private final MessageRepository messageRepository;
    private final UserRepository userRepository;

    public ChatRoom createEventChatRoom(String eventId, String eventTitle) {
        return chatRoomRepository.findByEventId(eventId).orElseGet(() -> {
            ChatRoom room = ChatRoom.builder().name(eventTitle + " Chat").type(ChatRoom.ChatRoomType.EVENT).eventId(eventId).participantIds(new ArrayList<>()).build();
            return chatRoomRepository.save(room);
        });
    }

    public ChatRoom createDirectChat(String userId1, String userId2) {
        return chatRoomRepository.findByTypeAndParticipantIdsContainingAndParticipantIdsContaining(ChatRoom.ChatRoomType.DIRECT, userId1, userId2)
                .orElseGet(() -> chatRoomRepository.save(ChatRoom.builder().name("Direct Chat").type(ChatRoom.ChatRoomType.DIRECT).participantIds(List.of(userId1, userId2)).build()));
    }

    public Message saveMessage(ChatDto.ChatMessage dto) {
        Message msg = Message.builder().chatRoomId(dto.getChatRoomId()).senderId(dto.getSenderId()).senderName(dto.getSenderName()).content(dto.getContent())
                .type(dto.getType() != null ? Message.MessageType.valueOf(dto.getType()) : Message.MessageType.TEXT).build();
        return messageRepository.save(msg);
    }

    public List<Message> getChatHistory(String chatRoomId, int page, int size) {
        return messageRepository.findByChatRoomIdOrderByCreatedAtDesc(chatRoomId, PageRequest.of(page, size));
    }

    public List<ChatRoom> getUserChatRooms(String userId) { return chatRoomRepository.findByParticipantIdsContaining(userId); }

    public void joinChatRoom(String chatRoomId, String userId) {
        chatRoomRepository.findById(chatRoomId).ifPresent(room -> { if (!room.getParticipantIds().contains(userId)) { room.getParticipantIds().add(userId); chatRoomRepository.save(room); }});
    }
}
