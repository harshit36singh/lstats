package com.example.lstats.auth.controller;

import java.util.List;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.lstats.model.User;
import com.example.lstats.model.friendmodel;
import com.example.lstats.repository.UserRepository;
import com.example.lstats.service.friendrequestservice;


@RestController
@RequestMapping("/friends")
public class FriendRequestController {

    private final friendrequestservice friendrequestService;
    private final SimpMessagingTemplate simpMessagingTemplate;

    public FriendRequestController(friendrequestservice friendrequestService,
                                   SimpMessagingTemplate simpMessagingTemplate) {
        this.friendrequestService = friendrequestService;
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    @PostMapping("/send")
    public friendmodel sendreq(@RequestParam Long senderid, @RequestParam Long receiverid) {

        friendmodel f = friendrequestService.sendreq(senderid, receiverid);

        // ✅ receiver username directly from entity
        String receiverUsername = f.getSender().getUsername();

        System.out.println("📨 Sending friend request WS to: " + receiverUsername);

        simpMessagingTemplate.convertAndSendToUser(
                receiverUsername,
                "/queue/friend",
                f
        );

        return f;
    }

    @PostMapping("/accept/{requestid}")
    public friendmodel acceptreq(@PathVariable Long requestid) {

        friendmodel f = friendrequestService.acceptreq(requestid);

        // ✅ sender username directly
        String senderUsername = f.getReceiver().getUsername();

        System.out.println("✅ Friend accepted → notifying: " + senderUsername);

        simpMessagingTemplate.convertAndSendToUser(
                senderUsername,
                "/queue/friend",
                f
        );

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
    public List<User> getFriends(@PathVariable Long userid) {
        return friendrequestService.getFriends(userid);
    }
}
