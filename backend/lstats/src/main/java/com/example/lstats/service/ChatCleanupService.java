package com.example.lstats.service;

import java.util.List;
import org.springframework.data.domain.PageRequest;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import com.example.lstats.model.Chat;
import com.example.lstats.repository.Charrepo;
import jakarta.transaction.Transactional;

@Service
public class ChatCleanupService {

    private final Charrepo charrepo;

    public ChatCleanupService(Charrepo charrepo) {
        this.charrepo = charrepo;
    }
    

    @Transactional
    @Scheduled(fixedRate = 3600000)
    public void deleteoldmessages(int limit){
        List<Chat> oldchatstodelete=charrepo.findoldchats(PageRequest.of(0,limit));
        charrepo.deleteAll(oldchatstodelete);

    }
}
