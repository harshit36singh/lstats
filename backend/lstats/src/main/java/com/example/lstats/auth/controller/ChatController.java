package com.example.lstats.auth.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.validation.annotation.Validated;

import com.example.lstats.auth.dto.ChatMessageDto;
import com.example.lstats.model.Chat;
import com.example.lstats.repository.Charrepo;
import com.example.lstats.service.OnlinePresenceService;

import jakarta.validation.Valid;

@Controller
public class ChatController {

    private final SimpMessagingTemplate simpMessagingTemplate;
    private final Charrepo charrepo;
    private final OnlinePresenceService o;

    public ChatController(SimpMessagingTemplate simpMessagingTemplate, Charrepo charrepo) {
        this.simpMessagingTemplate = simpMessagingTemplate;
        this.charrepo = charrepo;
        this.o = null;
    }

    @Validated
    @MessageMapping("/chat.send")
    @SendTo("/topic/Global")
    public ChatMessageDto sendmessage(@Valid ChatMessageDto c){
        c.setTimestamp(System.currentTimeMillis());
        Chat chat = new Chat();
        chat.setSender(c.getSender());
        chat.setContent(c.getContent());
        charrepo.save(chat);
        return c;
    }

    @MessageMapping("/chat.private")
    public void sendprivatemessage(ChatMessageDto c) {
        c.setTimestamp(System.currentTimeMillis());
        simpMessagingTemplate.convertAndSendToUser(c.getReceiver(), "/queue/private", c);
    }
     @MessageMapping("/presence.refresh")
    public void refreshPresence() {
        o.broadcastliveusers();
    }
}
