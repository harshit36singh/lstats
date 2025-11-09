package com.example.lstats.auth.dto;

import lombok.Data;

@Data
public class ChatMessageDto {
    private String sender;
    private String receiver;
    private String content;
    private long timestamp;
    
}
