package com.example.lstats.auth.controller;

import java.util.List;

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
    private final NotificationWebscocketcontroller notificationWebscocketcontroller;

    public NotificationController(NotificationService notificationservice) {
        this.notificationservice = notificationservice;
        this.notificationWebscocketcontroller = null;
    }

    @PostMapping("/create")
    public Notification createNotification(@RequestParam String name, @RequestParam String message) {
        Notification n = notificationservice.createNotification(name, message);
        NotificationDto d = new NotificationDto();
        d.setTargetuser(name);
        d.setMessage(message);
        d.setType("System");
        notificationWebscocketcontroller.sendn(d);
        return n;
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
