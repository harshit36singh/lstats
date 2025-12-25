package com.example.lstats.repository;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import com.example.lstats.model.Chat;

public interface Charrepo extends JpaRepository<Chat,Long>{

    @Query("Select c from Chat c Order By c.timestamp ASC ")
    List<Chat> findoldchats(Pageable p);
}
