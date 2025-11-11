package com.example.lstats.auth.controller;

import java.util.List;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.lstats.model.friendmodel;
import com.example.lstats.service.friendrequestservice;

@RestController
@RequestMapping("/friends")
public class FriendRequestController {
    private final friendrequestservice friendrequestService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    FriendRequestController(friendrequestservice f,SimpMessagingTemplate s) {
        this.friendrequestService = f;
        this.simpMessagingTemplate = s;

    }

    @PostMapping("/send")
    public friendmodel sendreq(@RequestParam Long senderid, @RequestParam Long receiverid) {
        friendmodel f= friendrequestService.sendreq(senderid, receiverid);
        simpMessagingTemplate.convertAndSendToUser(receiverid.toString(),"queue/friend",f);

        return f;

    }

    @PostMapping("/accept/{requestid}")
    public friendmodel acceptreq(@PathVariable Long requestid) {
        friendmodel f= friendrequestService.acceptreq(requestid);
        simpMessagingTemplate.convertAndSend("queue/friend"+f.getSender()+f);
        return f;
    }

    @PostMapping("/reject/{requestid}")
    public friendmodel rejectreq(@PathVariable Long requestid) {
        return friendrequestService.rejectreq(requestid);

    }

    @GetMapping("/pending/{userid}")
    public List<friendmodel> getpendingreq(@PathVariable Long userid) {
        return friendrequestService.getpendingreq(userid);

    }

    @GetMapping("/list/{userid}")
    public List<com.example.lstats.model.User> getFriends(@PathVariable Long userid) {
        return friendrequestService.getFriends(userid);
    }

}
