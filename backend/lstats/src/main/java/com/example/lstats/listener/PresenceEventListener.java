package com.example.lstats.listener;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import com.example.lstats.service.OnlinePresenceService;

@Component
public class PresenceEventListener {
    private final OnlinePresenceService onlinePresenceService;
 private final Map<String, String> sessionUserMap = new ConcurrentHashMap<>();

    public PresenceEventListener(OnlinePresenceService onlinePresenceService) {
        this.onlinePresenceService = onlinePresenceService;
    }
@EventListener
public void handleConnect(SessionConnectedEvent event) { // Changed here
    StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
    String sessionId = accessor.getSessionId();
    
    // Get username from Principal (set by interceptor)
    String username = accessor.getUser() != null ? accessor.getUser().getName() : null;
    
    System.out.println("🔌 SESSION CONNECTED");
    System.out.println("   Session: " + sessionId);
    System.out.println("   Username: " + username);

  if (username != null && sessionId != null) {
    sessionUserMap.put(sessionId, username);
    try {
        System.out.println("🔄 About to call userconnected for: " + username);
        onlinePresenceService.userconnected(username);

        System.out.println("🔄 userconnected call completed");
    } catch (Exception e) {
        System.out.println("❌ ERROR calling userconnected: " + e.getMessage());
        e.printStackTrace();
    }
}else {
        System.out.println("⚠️ Cannot track presence - username is null");
    }
}

    @EventListener
    public void handleDisconnect(SessionDisconnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String sessionId = accessor.getSessionId();

        if (sessionId != null && sessionUserMap.containsKey(sessionId)) {
            String username = sessionUserMap.remove(sessionId);
            onlinePresenceService.userdisconnected(username);
        }
    }
}
