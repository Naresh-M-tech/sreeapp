package com.eventbridge.service;

import com.eventbridge.dto.AnalyticsDto;
import com.eventbridge.model.*;
import com.eventbridge.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AnalyticsService {
    private final UserRepository userRepository;
    private final EventRepository eventRepository;
    private final RegistrationRepository registrationRepository;

    public AnalyticsDto.AdminAnalytics getAdminAnalytics() {
        Map<String, Long> usersByRole = new HashMap<>();
        for (User.Role role : User.Role.values()) usersByRole.put(role.name(), userRepository.countByRolesContaining(role));
        Map<String, Long> eventsByCategory = new HashMap<>();
        for (Event.EventCategory cat : Event.EventCategory.values()) eventsByCategory.put(cat.name(), eventRepository.countByCategory(cat));

        double totalRevenue = registrationRepository.findAll().stream().mapToDouble(Registration::getAmountPaid).sum();

        return AnalyticsDto.AdminAnalytics.builder()
                .totalUsers(userRepository.count()).totalEvents(eventRepository.count())
                .totalRegistrations(registrationRepository.count()).totalRevenue(totalRevenue)
                .activeUsers(userRepository.countByOnlineTrue()).pendingApprovals(eventRepository.countByStatus(Event.EventStatus.PENDING_APPROVAL))
                .usersByRole(usersByRole).eventsByCategory(eventsByCategory)
                .registrationsByMonth(new HashMap<>()).revenueByMonth(new HashMap<>()).build();
    }

    public AnalyticsDto.OrganizerAnalytics getOrganizerAnalytics(String organizerId) {
        List<Event> events = eventRepository.findByOrganizerId(organizerId);
        List<String> eventIds = events.stream().map(Event::getId).collect(Collectors.toList());
        long totalRegs = eventIds.stream().mapToLong(registrationRepository::countByEventId).sum();
        long totalAttendees = eventIds.stream().mapToLong(registrationRepository::countByEventIdAndAttendedTrue).sum();
        double totalRevenue = events.stream().mapToDouble(e -> registrationRepository.countByEventId(e.getId()) * e.getRegistrationFee()).sum();

        Map<String, Long> regsByEvent = new HashMap<>();
        events.forEach(e -> regsByEvent.put(e.getTitle(), registrationRepository.countByEventId(e.getId())));

        return AnalyticsDto.OrganizerAnalytics.builder()
                .totalEvents(events.size()).totalRegistrations(totalRegs).totalAttendees(totalAttendees).totalRevenue(totalRevenue)
                .registrationsByEvent(regsByEvent).registrationTrends(new HashMap<>()).attendanceRate(new HashMap<>()).build();
    }

    public AnalyticsDto.EventAnalytics getEventAnalytics(String eventId) {
        Event event = eventRepository.findById(eventId).orElse(null);
        if (event == null) return null;
        long totalRegs = registrationRepository.countByEventId(eventId);
        long confirmed = registrationRepository.countByEventIdAndStatus(eventId, Registration.RegistrationStatus.CONFIRMED);
        long attended = registrationRepository.countByEventIdAndAttendedTrue(eventId);
        double rate = totalRegs > 0 ? (double) attended / totalRegs * 100 : 0;

        return AnalyticsDto.EventAnalytics.builder()
                .eventId(eventId).eventTitle(event.getTitle()).totalRegistrations(totalRegs)
                .confirmedRegistrations(confirmed).attendees(attended).attendanceRate(rate)
                .revenue(totalRegs * event.getRegistrationFee()).registrationsByDay(new HashMap<>()).registrationsByDepartment(new HashMap<>()).build();
    }
}
