package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.service.UserService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/users")
@RequiredArgsConstructor
@Tag(name = "Users")
public class UserController {
    private final UserService userService;

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<AuthDto.UserInfo>> getProfile(@AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUserByEmail(user.getUsername())));
    }

    @PutMapping("/me")
    public ResponseEntity<ApiResponse<AuthDto.UserInfo>> updateProfile(@RequestBody AuthDto.RegisterRequest request, @AuthenticationPrincipal UserDetails user) {
        return ResponseEntity.ok(ApiResponse.success(userService.updateProfile(user.getUsername(), request)));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AuthDto.UserInfo>> getById(@PathVariable String id) {
        return ResponseEntity.ok(ApiResponse.success(userService.getUserById(id)));
    }

    @GetMapping("/search")
    public ResponseEntity<ApiResponse<?>> search(@RequestParam String q) {
        return ResponseEntity.ok(ApiResponse.success(userService.searchUsers(q)));
    }
}
