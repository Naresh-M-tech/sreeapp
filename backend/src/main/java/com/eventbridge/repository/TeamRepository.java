package com.eventbridge.repository;

import com.eventbridge.model.Team;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TeamRepository extends MongoRepository<Team, String> {
    List<Team> findByEventId(String eventId);
    List<Team> findByLeaderId(String leaderId);
    Optional<Team> findByEventIdAndLeaderId(String eventId, String leaderId);
    List<Team> findByMembersUserId(String userId);
    long countByEventId(String eventId);
}
