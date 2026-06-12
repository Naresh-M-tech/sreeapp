package com.eventbridge.controller;

import com.eventbridge.dto.*;
import com.eventbridge.model.*;
import com.eventbridge.repository.UserRepository;
import com.eventbridge.service.ChatService;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
@Tag(name = "Chat")
public class ChatController {
    private final ChatService chatService;
    private final UserRepository userRepository;

    @GetMapping("/rooms")
    public ResponseEntity<ApiResponse<List<ChatRoom>>> getMyRooms(@AuthenticationPrincipal UserDetails ud) {
        User user = userRepository.findByEmail(ud.getUsername()).orElseThrow();
        return ResponseEntity.ok(ApiResponse.success(chatService.getUserChatRooms(user.getId())));
    }

    @GetMapping("/rooms/{roomId}/messages")
    public ResponseEntity<ApiResponse<List<Message>>> getMessages(@PathVariable String roomId, @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "50") int size) {
        return ResponseEntity.ok(ApiResponse.success(chatService.getChatHistory(roomId, page, size)));
    }

    @PostMapping("/rooms/direct/{userId}")
    public ResponseEntity<ApiResponse<ChatRoom>> createDirect(@PathVariable String userId, @AuthenticationPrincipal UserDetails ud) {
        User user = userRepository.findByEmail(ud.getUsername()).orElseThrow();
        return ResponseEntity.ok(ApiResponse.success(chatService.createDirectChat(user.getId(), userId)));
    }

    @PostMapping("/rooms/{roomId}/join")
    public ResponseEntity<ApiResponse<Void>> joinRoom(@PathVariable String roomId, @AuthenticationPrincipal UserDetails ud) {
        User user = userRepository.findByEmail(ud.getUsername()).orElseThrow();
        chatService.joinChatRoom(roomId, user.getId());
        return ResponseEntity.ok(ApiResponse.success("Joined", null));
    }
}
