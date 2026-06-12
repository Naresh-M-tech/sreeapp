package com.eventbridge.repository;

import com.eventbridge.model.Announcement;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AnnouncementRepository extends MongoRepository<Announcement, String> {
    List<Announcement> findByPublishedTrueOrderByCreatedAtDesc();
    List<Announcement> findByEventIdOrderByCreatedAtDesc(String eventId);
    List<Announcement> findByTypeOrderByCreatedAtDesc(Announcement.AnnouncementType type);
}
