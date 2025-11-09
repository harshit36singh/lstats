package com.example.lstats.service;

import java.util.HashSet;
import java.util.Set;
import org.springframework.messaging.simp.SimpMessagingTemplate;

public class OnlinePresenceService {
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final Set<String> onlineusers = new HashSet<>();

    public OnlinePresenceService(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void userconnected(String username) {
        onlineusers.add(username);
        broadcastliveusers();

    }

    public void userdisconnected(String username) {
        onlineusers.remove(username);
        broadcastliveusers();
    }

    public void broadcastliveusers() {
        simpMessagingTemplate.convertAndSend("topic/presence", onlineusers);
    }
}
