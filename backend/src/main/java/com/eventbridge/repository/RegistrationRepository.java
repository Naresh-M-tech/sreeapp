package com.eventbridge.repository;

import com.eventbridge.model.Registration;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface RegistrationRepository extends MongoRepository<Registration, String> {
    List<Registration> findByUserId(String userId);
    List<Registration> findByEventId(String eventId);
    Optional<Registration> findByUserIdAndEventId(String userId, String eventId);
    boolean existsByUserIdAndEventId(String userId, String eventId);
    long countByEventId(String eventId);
    long countByEventIdAndStatus(String eventId, Registration.RegistrationStatus status);
    long countByEventIdAndAttendedTrue(String eventId);
    List<Registration> findByEventIdAndStatus(String eventId, Registration.RegistrationStatus status);
    List<Registration> findByTeamId(String teamId);
}
