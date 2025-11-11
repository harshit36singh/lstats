package com.example.lstats.auth.controller;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import com.example.lstats.auth.dto.NotificationDto;

@Controller
public class NotificationWebscocketcontroller {

    private final SimpMessagingTemplate simpMessagingTemplate;

    public NotificationWebscocketcontroller(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void sendn(NotificationDto n) {
        simpMessagingTemplate.convertAndSend("/queue/notifications" + n.getTargetuser() ,n.getMessage());

    }
}
