package com.example.lstats.model;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Entity
@Data
@Table(name="chat_messages")
public class Chat {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @Column(nullable = false)
    private String sender;


    @Column(nullable = false,length = 100)
    @Size(max=100,message="Cant extend the size more than 100 words .")
    private String content;

    private LocalDateTime timestamp=LocalDateTime.now();

}
