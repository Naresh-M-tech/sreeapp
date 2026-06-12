package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.Announcement;
import com.eventbridge.service.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/announcements")
@RequiredArgsConstructor
@Tag(name = "Announcements")
public class AnnouncementController {
    private final AnnouncementService announcementService;

    @PostMapping
    public ResponseEntity<ApiResponse<Announcement>> create(@RequestBody Announcement announcement, @AuthenticationPrincipal UserDetails user) {
        announcement.setCreatedBy(user.getUsername());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Created", announcementService.create(announcement)));
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<Announcement>>> getAll() {
        return ResponseEntity.ok(ApiResponse.success(announcementService.getAll()));
    }

    @GetMapping("/event/{eventId}")
    public ResponseEntity<ApiResponse<List<Announcement>>> getByEvent(@PathVariable String eventId) {
        return ResponseEntity.ok(ApiResponse.success(announcementService.getByEvent(eventId)));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> delete(@PathVariable String id) {
        announcementService.delete(id);
        return ResponseEntity.ok(ApiResponse.success("Deleted", null));
    }
}
