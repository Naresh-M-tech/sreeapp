package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.service.*;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
@Tag(name = "Admin", description = "Admin Management APIs")
public class AdminController {
    private final UserService userService;
    private final EventService eventService;
    private final AnalyticsService analyticsService;
    private final AuditService auditService;

    @GetMapping("/analytics")
    public ResponseEntity<ApiResponse<AnalyticsDto.AdminAnalytics>> getAnalytics() {
        return ResponseEntity.ok(ApiResponse.success(analyticsService.getAdminAnalytics()));
    }

    @GetMapping("/users")
    public ResponseEntity<ApiResponse<List<AuthDto.UserInfo>>> getAllUsers() {
        return ResponseEntity.ok(ApiResponse.success(userService.getAllUsers()));
    }

    @GetMapping("/users/role/{role}")
    public ResponseEntity<ApiResponse<List<AuthDto.UserInfo>>> getUsersByRole(@PathVariable String role) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUsersByRole(role)));
    }

    @PutMapping("/users/{id}/toggle-status")
    public ResponseEntity<ApiResponse<Void>> toggleStatus(@PathVariable String id) {
        userService.toggleUserStatus(id);
        return ResponseEntity.ok(ApiResponse.success("Status toggled", null));
    }

    @PutMapping("/users/{id}/roles")
    public ResponseEntity<ApiResponse<Void>> updateRoles(@PathVariable String id, @RequestBody Set<String> roles) {
        userService.updateUserRoles(id, roles);
        return ResponseEntity.ok(ApiResponse.success("Roles updated", null));
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteUser(@PathVariable String id) {
        userService.deleteUser(id);
        return ResponseEntity.ok(ApiResponse.success("User deleted", null));
    }

    @GetMapping("/events/pending")
    public ResponseEntity<ApiResponse<?>> getPendingEvents() {
        return ResponseEntity.ok(ApiResponse.success(eventService.getPendingApprovalEvents()));
    }

    @PutMapping("/events/{id}/approve")
    public ResponseEntity<ApiResponse<?>> approveEvent(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(eventService.approveEvent(id)));
    }

    @PutMapping("/events/{id}/reject")
    public ResponseEntity<ApiResponse<?>> rejectEvent(@PathVariable String id, @RequestParam String reason) {
        return ResponseEntity.ok(ApiResponse.success(eventService.rejectEvent(id, reason)));
    }

    @GetMapping("/audit-logs")
    public ResponseEntity<ApiResponse<?>> getAuditLogs() {
        return ResponseEntity.ok(ApiResponse.success(auditService.getRecentLogs()));
    }
}
