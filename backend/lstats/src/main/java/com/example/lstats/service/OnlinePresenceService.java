package com.example.lstats.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.Set;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class OnlinePresenceService {
    private final SimpMessagingTemplate simpMessagingTemplate;
    private final Set<String> onlineusers = Collections.synchronizedSet(new HashSet<>());

    public OnlinePresenceService(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void userconnected(String username) {
        boolean added = onlineusers.add(username);
        System.out.println("✅ userconnected() called for: " + username);
        System.out.println("   Was new user? " + added);
        System.out.println("   Total online: " + onlineusers.size());
        System.out.println("   Online users: " + onlineusers);
        broadcastliveusers();
    }

    public void userdisconnected(String username) {
        boolean removed = onlineusers.remove(username);
        System.out.println("❌ userdisconnected() called for: " + username);
        System.out.println("   Was removed? " + removed);
        System.out.println("   Total online: " + onlineusers.size());
        System.out.println("   Online users: " + onlineusers);
        broadcastliveusers();
    }

    public void broadcastliveusers() {
        ArrayList<String> userList = new ArrayList<>(onlineusers);
        System.out.println("📡 Broadcasting to /topic/presence: " + userList);
        simpMessagingTemplate.convertAndSend("/topic/presence", userList);
        System.out.println("✅ Broadcast complete");
    }

    public Set<String> getOnlineUsers() {
        return new HashSet<>(onlineusers);
    }
}