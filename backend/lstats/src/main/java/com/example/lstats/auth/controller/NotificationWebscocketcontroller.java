package com.example.lstats.auth.controller;

import org.springframework.messaging.simp.SimpMessagingTemplate;

import com.example.lstats.auth.dto.NotificationDto;

public class NotificationWebscocketcontroller {

    private final SimpMessagingTemplate simpMessagingTemplate;

    public NotificationWebscocketcontroller(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void sendn(NotificationDto n) {
        simpMessagingTemplate.convertAndSend("/queue/notifications" + n.getTargetuser() + n.getMessage());

    }
}
