package com.example.lstats.auth.controller;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;

import com.example.lstats.auth.dto.ChatMessageDto;
import com.example.lstats.model.Chat;
import com.example.lstats.repository.Charrepo;

public class ChatController {
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final Charrepo charrepo;

    public ChatController(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
        this.charrepo = null;
    }
    

    @MessageMapping("/chat.send")
    @SendTo("/topic/Global")
    public ChatMessageDto sendmessage(ChatMessageDto c){
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
