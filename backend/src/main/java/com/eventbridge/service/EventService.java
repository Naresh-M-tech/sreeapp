package com.eventbridge.service;

import com.eventbridge.dto.EventDto;
import com.eventbridge.exception.*;
import com.eventbridge.model.*;
import com.eventbridge.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class EventService {

    private final EventRepository eventRepository;
    private final RegistrationRepository registrationRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final AuditService auditService;

    public Event createEvent(EventDto.CreateRequest request, String organizerEmail) {
        User organizer = userRepository.findByEmail(organizerEmail)
                .orElseThrow(() -> new ResourceNotFoundException("Organizer not found"));

        Event event = Event.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .category(request.getCategory())
                .venue(request.getVenue())
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .registrationDeadline(request.getRegistrationDeadline())
                .organizerId(organizer.getId())
                .organizerName(organizer.getName())
                .capacity(request.getCapacity())
                .bannerImageUrl(request.getBannerImageUrl())
                .rules(request.getRules())
                .eligibility(request.getEligibility())
                .registrationFee(request.getRegistrationFee())
                .contactInfo(request.getContactInfo())
                .teamEvent(request.isTeamEvent())
                .minTeamSize(request.getMinTeamSize())
                .maxTeamSize(request.getMaxTeamSize())
                .tags(request.getTags())
                .status(Event.EventStatus.PENDING_APPROVAL)
                .build();

        Event saved = eventRepository.save(event);
        auditService.log(organizer.getId(), organizer.getName(), "EVENT_CREATED", "Event", saved.getId(), "Event created: " + saved.getTitle());
        return saved;
    }

    public Event updateEvent(String eventId, EventDto.UpdateRequest request, String email) {
        Event event = getEventById(eventId);
        verifyOrganizer(event, email);

        if (request.getTitle() != null) event.setTitle(request.getTitle());
        if (request.getDescription() != null) event.setDescription(request.getDescription());
        if (request.getCategory() != null) event.setCategory(request.getCategory());
        if (request.getVenue() != null) event.setVenue(request.getVenue());
        if (request.getStartDate() != null) event.setStartDate(request.getStartDate());
        if (request.getEndDate() != null) event.setEndDate(request.getEndDate());
        if (request.getRegistrationDeadline() != null) event.setRegistrationDeadline(request.getRegistrationDeadline());
        if (request.getCapacity() > 0) event.setCapacity(request.getCapacity());
        if (request.getBannerImageUrl() != null) event.setBannerImageUrl(request.getBannerImageUrl());
        if (request.getRules() != null) event.setRules(request.getRules());
        if (request.getEligibility() != null) event.setEligibility(request.getEligibility());
        if (request.getRegistrationFee() >= 0) event.setRegistrationFee(request.getRegistrationFee());
        if (request.getContactInfo() != null) event.setContactInfo(request.getContactInfo());
        if (request.getTags() != null) event.setTags(request.getTags());
        event.setTeamEvent(request.isTeamEvent());
        event.setMinTeamSize(request.getMinTeamSize());
        event.setMaxTeamSize(request.getMaxTeamSize());

        return eventRepository.save(event);
    }

    public void deleteEvent(String eventId, String email) {
        Event event = getEventById(eventId);
        verifyOrganizer(event, email);
        eventRepository.deleteById(eventId);
        auditService.log(null, null, "EVENT_DELETED", "Event", eventId, "Event deleted: " + event.getTitle());
    }

    public Event getEventById(String id) {
        return eventRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Event not found with id: " + id));
    }

    public List<Event> getAllEvents() {
        return eventRepository.findAll();
    }

    public List<Event> getPublishedEvents() {
        return eventRepository.findByStatus(Event.EventStatus.PUBLISHED);
    }

    public List<Event> getUpcomingEvents() {
        return eventRepository.findByStartDateAfterAndStatus(LocalDateTime.now(), Event.EventStatus.PUBLISHED);
    }

    public List<Event> getEventsByOrganizer(String organizerId) {
        return eventRepository.findByOrganizerId(organizerId);
    }

    public List<Event> getEventsByCategory(Event.EventCategory category) {
        return eventRepository.findByCategory(category);
    }

    public List<Event> searchEvents(String query) {
        return eventRepository.findByTitleContainingIgnoreCaseAndStatus(query, Event.EventStatus.PUBLISHED);
    }

    public List<Event> getPendingApprovalEvents() {
        return eventRepository.findByStatus(Event.EventStatus.PENDING_APPROVAL);
    }

    public Event approveEvent(String eventId) {
        Event event = getEventById(eventId);
        event.setStatus(Event.EventStatus.PUBLISHED);
        Event saved = eventRepository.save(event);
        notificationService.createNotification(event.getOrganizerId(), "Event Approved",
                "Your event '" + event.getTitle() + "' has been approved and published.",
                Notification.NotificationType.EVENT, eventId, "Event");
        return saved;
    }

    public Event rejectEvent(String eventId, String reason) {
        Event event = getEventById(eventId);
        event.setStatus(Event.EventStatus.CANCELLED);
        Event saved = eventRepository.save(event);
        notificationService.createNotification(event.getOrganizerId(), "Event Rejected",
                "Your event '" + event.getTitle() + "' was rejected. Reason: " + reason,
                Notification.NotificationType.EVENT, eventId, "Event");
        return saved;
    }

    public Event updateEventStatus(String eventId, Event.EventStatus status) {
        Event event = getEventById(eventId);
        event.setStatus(status);
        return eventRepository.save(event);
    }

    public EventDto.EventResponse toEventResponse(Event event, String userId) {
        boolean isRegistered = false;
        if (userId != null) {
            isRegistered = registrationRepository.existsByUserIdAndEventId(userId, event.getId());
        }

        return EventDto.EventResponse.builder()
                .id(event.getId())
                .title(event.getTitle())
                .description(event.getDescription())
                .category(event.getCategory())
                .venue(event.getVenue())
                .startDate(event.getStartDate())
                .endDate(event.getEndDate())
                .registrationDeadline(event.getRegistrationDeadline())
                .organizerId(event.getOrganizerId())
                .organizerName(event.getOrganizerName())
                .capacity(event.getCapacity())
                .registeredCount(event.getRegisteredCount())
                .bannerImageUrl(event.getBannerImageUrl())
                .rules(event.getRules())
                .eligibility(event.getEligibility())
                .registrationFee(event.getRegistrationFee())
                .contactInfo(event.getContactInfo())
                .teamEvent(event.isTeamEvent())
                .minTeamSize(event.getMinTeamSize())
                .maxTeamSize(event.getMaxTeamSize())
                .status(event.getStatus())
                .tags(event.getTags())
                .createdAt(event.getCreatedAt() != null ? event.getCreatedAt().toString() : null)
                .updatedAt(event.getUpdatedAt() != null ? event.getUpdatedAt().toString() : null)
                .isRegistered(isRegistered)
                .build();
    }

    private void verifyOrganizer(Event event, String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (!event.getOrganizerId().equals(user.getId()) && !user.getRoles().contains(User.Role.ROLE_ADMIN)) {
            throw new BadRequestException("You are not authorized to modify this event");
        }
    }
}
