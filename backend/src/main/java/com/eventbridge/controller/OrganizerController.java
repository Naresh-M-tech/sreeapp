package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.User;
import com.eventbridge.repository.UserRepository;
import com.eventbridge.service.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/organizer")
@RequiredArgsConstructor
@PreAuthorize("hasAnyRole('ADMIN','ORGANIZER')")
@Tag(name = "Organizer")
public class OrganizerController {
    private final EventService eventService;
    private final AnalyticsService analyticsService;
    private final UserRepository userRepository;

    @GetMapping("/analytics")
    public ResponseEntity<ApiResponse<AnalyticsDto.OrganizerAnalytics>> getAnalytics(@AuthenticationPrincipal UserDetails ud) {
        User user = userRepository.findByEmail(ud.getUsername()).orElseThrow();
        return ResponseEntity.ok(ApiResponse.success(analyticsService.getOrganizerAnalytics(user.getId())));
    }

    @GetMapping("/events")
    public ResponseEntity<ApiResponse<?>> getMyEvents(@AuthenticationPrincipal UserDetails ud) {
        User user = userRepository.findByEmail(ud.getUsername()).orElseThrow();
        return ResponseEntity.ok(ApiResponse.success(eventService.getEventsByOrganizer(user.getId())));
    }

    @GetMapping("/events/{eventId}/analytics")
    public ResponseEntity<ApiResponse<AnalyticsDto.EventAnalytics>> getEventAnalytics(@PathVariable String eventId) {
        return ResponseEntity.ok(ApiResponse.success(analyticsService.getEventAnalytics(eventId)));
    }
}
