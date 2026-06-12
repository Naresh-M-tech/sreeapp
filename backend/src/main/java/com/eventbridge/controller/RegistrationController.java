package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.Registration;
import com.eventbridge.service.RegistrationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.*;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/registrations")
@RequiredArgsConstructor
@Tag(name = "Registrations")
public class RegistrationController {
    private final RegistrationService registrationService;

    @PostMapping("/{eventId}")
    public ResponseEntity<ApiResponse<Registration>> register(@PathVariable String eventId, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.created("Registered", registrationService.registerForEvent(eventId, user.getUsername())));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> cancel(@PathVariable String id, @AuthenticationPrincipal UserDetails user) {
        registrationService.cancelRegistration(id, user.getUsername());
        return ResponseEntity.ok(ApiResponse.success("Cancelled", null));
    }

    @GetMapping("/my")
    public ResponseEntity<ApiResponse<List<Registration>>> myRegistrations(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(registrationService.getMyRegistrations(user.getUsername())));
    }

    @GetMapping("/event/{eventId}")
    public ResponseEntity<ApiResponse<List<Registration>>> eventRegistrations(@PathVariable String eventId) {
        return ResponseEntity.ok(ApiResponse.success(registrationService.getEventRegistrations(eventId)));
    }

    @PutMapping("/{id}/attendance")
    public ResponseEntity<ApiResponse<Registration>> markAttendance(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(registrationService.markAttendance(id)));
    }

    @PutMapping("/{id}/confirm")
    public ResponseEntity<ApiResponse<Registration>> confirm(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(registrationService.confirmRegistration(id)));
    }
}
