package com.eventbridge.controller;

import com.eventbridge.dto.ChatDto;
import com.eventbridge.model.Message;
import com.eventbridge.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.*;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatWebSocketController {
    private final ChatService chatService;
    private final SimpMessagingTemplate messagingTemplate;

    @MessageMapping("/chat.send")
    public void sendMessage(@Payload ChatDto.ChatMessage chatMessage) {
        Message saved = chatService.saveMessage(chatMessage);
        messagingTemplate.convertAndSend("/topic/chat/" + chatMessage.getChatRoomId(), saved);
    }

    @MessageMapping("/chat.typing")
    public void typing(@Payload ChatDto.TypingIndicator indicator) {
        messagingTemplate.convertAndSend("/topic/chat/" + indicator.getChatRoomId() + "/typing", indicator);
    }
}
