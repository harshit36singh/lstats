package com.example.lstats.auth.controller;

import java.util.List;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.example.lstats.auth.dto.NotificationDto;
import com.example.lstats.model.User;
import com.example.lstats.model.friendmodel;
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
         String senderUsername = friendrequestService.getUsernamebyid(senderid);
    String receiverUsername = friendrequestService.getUsernamebyid(receiverid);

    NotificationDto dto = new NotificationDto();
    dto.setTargetuser(receiverUsername);
    dto.setType("FRIEND_REQUEST");
    dto.setMessage(senderUsername + " sent you a friend request!");

    simpMessagingTemplate.convertAndSendToUser(
            receiverUsername,
            "/queue/notifications",
            dto
    );

        return f;
    }

    @PostMapping("/accept/{requestid}")
    public friendmodel acceptreq(@PathVariable Long requestid) {

        friendmodel f = friendrequestService.acceptreq(requestid);

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
