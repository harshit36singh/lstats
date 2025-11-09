package com.example.lstats.auth.dto;

import lombok.Data;

@Data
public class NotificationDto {
    private String targetuser;
    private String message;
    private String type;
    
}
