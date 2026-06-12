package com.eventbridge.repository;

import com.eventbridge.model.Message;
import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface MessageRepository extends MongoRepository<Message, String> {
    List<Message> findByChatRoomIdOrderByCreatedAtDesc(String chatRoomId, Pageable pageable);
    List<Message> findByChatRoomIdOrderByCreatedAtAsc(String chatRoomId);
    long countByChatRoomId(String chatRoomId);
}
