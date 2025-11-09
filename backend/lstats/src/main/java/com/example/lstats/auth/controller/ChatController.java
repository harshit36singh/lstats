package com.example.lstats.auth.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.validation.annotation.Validated;

import com.example.lstats.auth.dto.ChatMessageDto;
import com.example.lstats.model.Chat;
import com.example.lstats.repository.Charrepo;

import jakarta.validation.Valid;

public class ChatController {
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final Charrepo charrepo;

    public ChatController(SimpMessagingTemplate simpMessagingTemplate,Charrepo charrepo) {
        this.simpMessagingTemplate = simpMessagingTemplate;
        this.charrepo = charrepo;
    }
    

    @Validated
    @MessageMapping("/chat.send")
    @SendTo("/topic/Global")
    public ChatMessageDto sendmessage(@Valid ChatMessageDto c){
        c.setTimestamp(System.currentTimeMillis());
        Chat chat=new Chat();
        chat.setSender(c.getSender());
        chat.setContent(c.getContent());
        charrepo.save(chat);
        return c;
    } 


    @MessageMapping("/chat.private")
    public void sendprivatemessage(ChatMessageDto c){
        c.setTimestamp(System.currentTimeMillis());
        simpMessagingTemplate.convertAndSend("/queue/user"+c.getReceiver()+c);
        
    }




}
