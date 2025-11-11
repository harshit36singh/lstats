package com.example.lstats.listener;

import java.util.HashMap;
import java.util.Map;

import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;
import com.example.lstats.service.OnlinePresenceService;

@Component
public class PresenceEventListener {
    private final OnlinePresenceService onlinePresenceService;
    private final Map<String, String> sessionUserMap = new HashMap<>();

    public PresenceEventListener(OnlinePresenceService onlinePresenceService) {
        this.onlinePresenceService = onlinePresenceService;
    }

    @EventListener
    public void handleConnect(SessionConnectEvent event) {
        StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
        String username = accessor.getFirstNativeHeader("username");
        String sessionId = accessor.getSessionId();

        if (username != null && sessionId != null) {
            sessionUserMap.put(sessionId, username);
            onlinePresenceService.userconnected(username);
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
