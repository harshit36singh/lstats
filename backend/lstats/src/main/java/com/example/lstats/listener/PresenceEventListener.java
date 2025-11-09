package com.example.lstats.listener;

import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.web.socket.messaging.SessionConnectEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import com.example.lstats.service.OnlinePresenceService;

public class PresenceEventListener {
    private final OnlinePresenceService onlinePresenceService;

    public PresenceEventListener(OnlinePresenceService onlinePresenceService) {
        this.onlinePresenceService = onlinePresenceService;
    }
    

    @EventListener
    public void handleconnect(SessionConnectEvent s){
        String name=StompHeaderAccessor.wrap(s.getMessage()).getFirstNativeHeader("username");
        if(name!=null) onlinePresenceService.userconnected(name);
    }


    @EventListener
    public void handledisconnect(SessionDisconnectEvent s){
        String name=StompHeaderAccessor.wrap(s.getMessage()).getFirstNativeHeader("username");
        if(name!=null)onlinePresenceService.userdisconnected(name);

    }
}
