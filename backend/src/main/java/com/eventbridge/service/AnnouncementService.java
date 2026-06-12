package com.eventbridge.service;

import com.eventbridge.model.Announcement;
import com.eventbridge.repository.AnnouncementRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AnnouncementService {
    private final AnnouncementRepository announcementRepository;

    public Announcement create(Announcement announcement) { return announcementRepository.save(announcement); }
    public List<Announcement> getAll() { return announcementRepository.findByPublishedTrueOrderByCreatedAtDesc(); }
    public List<Announcement> getByEvent(String eventId) { return announcementRepository.findByEventIdOrderByCreatedAtDesc(eventId); }
    public Announcement getById(String id) { return announcementRepository.findById(id).orElseThrow(() -> new com.eventbridge.exception.ResourceNotFoundException("Not found")); }
    public void delete(String id) { announcementRepository.deleteById(id); }
}
