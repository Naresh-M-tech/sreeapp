package com.eventbridge.service;

import com.eventbridge.exception.*;
import com.eventbridge.model.*;
import com.eventbridge.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class RegistrationService {

    private final RegistrationRepository registrationRepository;
    private final EventRepository eventRepository;
    private final UserRepository userRepository;
    private final NotificationService notificationService;
    private final EmailService emailService;

    public Registration registerForEvent(String eventId, String email) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Event not found"));

        if (registrationRepository.existsByUserIdAndEventId(user.getId(), eventId)) {
            throw new DuplicateResourceException("Already registered for this event");
        }

        if (event.getCapacity() > 0 && event.getRegisteredCount() >= event.getCapacity()) {
            throw new BadRequestException("Event is at full capacity");
        }

        Registration registration = Registration.builder()
                .userId(user.getId()).userName(user.getName())
                .userEmail(user.getEmail()).eventId(eventId)
                .eventTitle(event.getTitle())
                .status(Registration.RegistrationStatus.REGISTERED)
                .amountPaid(event.getRegistrationFee()).build();

        Registration saved = registrationRepository.save(registration);
        event.setRegisteredCount(event.getRegisteredCount() + 1);
        eventRepository.save(event);

        notificationService.createNotification(user.getId(), "Registration Successful",
                "You have been registered for " + event.getTitle(),
                Notification.NotificationType.REGISTRATION, eventId, "Event");
        emailService.sendRegistrationConfirmation(user.getEmail(), user.getName(), event.getTitle());
        return saved;
    }

    public void cancelRegistration(String registrationId, String email) {
        Registration reg = registrationRepository.findById(registrationId)
                .orElseThrow(() -> new ResourceNotFoundException("Registration not found"));
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        if (!reg.getUserId().equals(user.getId())) throw new BadRequestException("Not your registration");
        reg.setStatus(Registration.RegistrationStatus.CANCELLED);
        registrationRepository.save(reg);
        eventRepository.findById(reg.getEventId()).ifPresent(e -> {
            e.setRegisteredCount(Math.max(0, e.getRegisteredCount() - 1));
            eventRepository.save(e);
        });
    }

    public List<Registration> getMyRegistrations(String email) {
        User user = userRepository.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return registrationRepository.findByUserId(user.getId());
    }

    public List<Registration> getEventRegistrations(String eventId) {
        return registrationRepository.findByEventId(eventId);
    }

    public Registration markAttendance(String registrationId) {
        Registration reg = registrationRepository.findById(registrationId).orElseThrow(() -> new ResourceNotFoundException("Not found"));
        reg.setAttended(true);
        reg.setStatus(Registration.RegistrationStatus.ATTENDED);
        return registrationRepository.save(reg);
    }

    public Registration confirmRegistration(String registrationId) {
        Registration reg = registrationRepository.findById(registrationId).orElseThrow(() -> new ResourceNotFoundException("Not found"));
        reg.setStatus(Registration.RegistrationStatus.CONFIRMED);
        return registrationRepository.save(reg);
    }
}
