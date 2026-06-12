package com.eventbridge.repository;

import com.eventbridge.model.Event;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface EventRepository extends MongoRepository<Event, String> {
    List<Event> findByOrganizerId(String organizerId);
    List<Event> findByStatus(Event.EventStatus status);
    List<Event> findByCategory(Event.EventCategory category);
    List<Event> findByStatusIn(List<Event.EventStatus> statuses);
    List<Event> findByStartDateAfterAndStatus(LocalDateTime date, Event.EventStatus status);
    List<Event> findByStartDateBetween(LocalDateTime start, LocalDateTime end);
    List<Event> findByTitleContainingIgnoreCaseAndStatus(String title, Event.EventStatus status);
    long countByOrganizerId(String organizerId);
    long countByStatus(Event.EventStatus status);
    long countByCategory(Event.EventCategory category);
}
