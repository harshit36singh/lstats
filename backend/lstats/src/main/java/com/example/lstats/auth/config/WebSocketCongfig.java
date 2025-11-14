package com.example.lstats.auth.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;


@Configuration
@EnableWebSocketMessageBroker
public class WebSocketCongfig implements WebSocketMessageBrokerConfigurer{
 
    @Override
    public void registerStompEndpoints(StompEndpointRegistry s){
        s.addEndpoint("/ws").setAllowedOrigins("*");

    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry m){
        m.enableSimpleBroker("/topic","queue");
        m.setApplicationDestinationPrefixes("/app");
        m.setUserDestinationPrefix("/user");

    }


    @Override
    public void configureClientInboundChannel(ChannelRegistration r){
        r.interceptors(new ChannelInterceptor(){
            public Message<?> preSend(Message<?> m,MessageChannel mc){
                StompHeaderAccessor a=MessageHeaderAccessor.getAccessor(m,StompHeaderAccessor.class);
                if(a!=null && StompCommand.CONNECT.equals(a.getCommand())){
                    String username=a.getFirstNativeHeader("username");
                    if(username!=null && !username.isEmpty()){
                        a.setUser(()->username);
                    }
                }

          return m;  }

        });

    }
}
