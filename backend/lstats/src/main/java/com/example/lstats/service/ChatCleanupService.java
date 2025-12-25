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
    private static final long m=262_000;

    public ChatCleanupService(Charrepo charrepo) {
        this.charrepo = charrepo;
    }
    

    @Transactional
    @Scheduled(fixedRate = 3600000)
    public void deleteoldmessages(){
        long usedm=charrepo.count();
        if(usedm>m){
            int batchsize=100;
        List<Chat> oldchatstodelete=charrepo.findoldchats(PageRequest.of(0,batchsize));
        if(!oldchatstodelete.isEmpty()){
            charrepo.deleteAll(oldchatstodelete);
            
        }
        }
    }
}
