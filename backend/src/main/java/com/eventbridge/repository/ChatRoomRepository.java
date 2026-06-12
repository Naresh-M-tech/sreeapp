package com.eventbridge.repository;

import com.eventbridge.model.ChatRoom;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ChatRoomRepository extends MongoRepository<ChatRoom, String> {
    Optional<ChatRoom> findByEventId(String eventId);
    List<ChatRoom> findByParticipantIdsContaining(String userId);
    Optional<ChatRoom> findByTypeAndParticipantIdsContainingAndParticipantIdsContaining(
            ChatRoom.ChatRoomType type, String userId1, String userId2);
}
