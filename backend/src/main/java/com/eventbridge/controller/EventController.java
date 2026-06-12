package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.Event;
import com.eventbridge.service.EventService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/events")
@RequiredArgsConstructor
@Tag(name = "Events", description = "Event Management APIs")
public class EventController {
    private final EventService eventService;

    @PostMapping
    @Operation(summary = "Create event")
    public ResponseEntity<ApiResponse<Event>> create(@Valid @RequestBody EventDto.CreateRequest request, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Event created", eventService.createEvent(request, user.getUsername())));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update event")
    public ResponseEntity<ApiResponse<Event>> update(@PathVariable String id, @RequestBody EventDto.UpdateRequest request, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(eventService.updateEvent(id, request, user.getUsername())));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String id, @AuthenticationPrincipal UserDetails user) {
        eventService.deleteEvent(id, user.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Event deleted", null));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<EventDto.EventResponse>> getById(@PathVariable String id, @AuthenticationPrincipal UserDetails user) {
        Event event = eventService.getEventById(id);
        return ResponseEntity.ok(ApiResponse.success(eventService.toEventResponse(event, user != null ? user.getUsername() : null)));
    }

    @GetMapping("/public/published")
    public ResponseEntity<ApiResponse<List<EventDto.EventResponse>>> getPublished() {
        return ResponseEntity.ok(ApiResponse.success(eventService.getPublishedEvents().stream().map(e -> eventService.toEventResponse(e, null)).collect(Collectors.toList())));
    }

    @GetMapping("/public/upcoming")
    public ResponseEntity<ApiResponse<List<EventDto.EventResponse>>> getUpcoming() {
        return ResponseEntity.ok(ApiResponse.success(eventService.getUpcomingEvents().stream().map(e -> eventService.toEventResponse(e, null)).collect(Collectors.toList())));
    }

    @GetMapping("/public/search")
    public ResponseEntity<ApiResponse<List<EventDto.EventResponse>>> search(@RequestParam String q) {
        return ResponseEntity.ok(ApiResponse.success(eventService.searchEvents(q).stream().map(e -> eventService.toEventResponse(e, null)).collect(Collectors.toList())));
    }

    @GetMapping("/public/category/{category}")
    public ResponseEntity<ApiResponse<List<EventDto.EventResponse>>> getByCategory(@PathVariable String category) {
        return ResponseEntity.ok(ApiResponse.success(eventService.getEventsByCategory(Event.EventCategory.valueOf(category.toUpperCase())).stream().map(e -> eventService.toEventResponse(e, null)).collect(Collectors.toList())));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Event>>> getMyEvents(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(eventService.getAllEvents())); // filtered by auth in service
    }
}
