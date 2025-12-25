package com.example.lstats.auth.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.lstats.auth.dto.NotificationDto;
import com.example.lstats.model.Notification;
import com.example.lstats.service.NotificationService;

@RestController
@RequestMapping("/notification")
public class NotificationController {

    private final NotificationService notificationservice;
    private final SimpMessagingTemplate messagingTemplate;

    public NotificationController(NotificationService notificationservice,
                                  SimpMessagingTemplate messagingTemplate) {
        this.notificationservice = notificationservice;
        this.messagingTemplate = messagingTemplate;
    }

    @PostMapping("/create")
    public Notification createNotification(@RequestParam String name,
                                           @RequestParam String message) {

        Notification n = notificationservice.createNotification(name, message);

        NotificationDto dto = new NotificationDto();
        dto.setTargetuser(name);
        dto.setMessage(message);
        dto.setType("System");

        // 🚀 Send WebSocket message
        messagingTemplate.convertAndSendToUser(
                name,
                "/queue/notifications",
                dto
        );

        return n;
    }

    @PostMapping("/test")
    public ResponseEntity<String> testNotification(@RequestParam String username) {

        NotificationDto dto = new NotificationDto();
        dto.setTargetuser(username);
        dto.setMessage("🚀 Test notification sent at " + System.currentTimeMillis());
        dto.setType("TEST");

        messagingTemplate.convertAndSendToUser(
                username,
                "/queue/notifications",
                dto
        );

        return ResponseEntity.ok("Notification sent to " + username);
    }

    @GetMapping("/unread")
    public List<Notification> unreadmessage(@RequestParam String username) {
        return notificationservice.getunreadnotification(username);
    }

    @PostMapping("{id}/read")
    public void markasread(@PathVariable Long id) {
        notificationservice.markAsRead(id);
    }
}
