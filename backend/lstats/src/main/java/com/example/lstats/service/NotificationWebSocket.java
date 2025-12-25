package com.example.lstats.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class NotificationWebSocket {
    @Autowired
    private SimpMessagingTemplate sm;


    public void sendnotification(String username,String msg){
        sm.convertAndSendToUser(username,"/queue/notifications", msg);

    }
    
}
