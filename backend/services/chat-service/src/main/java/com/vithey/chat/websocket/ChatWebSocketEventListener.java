package com.vithey.chat.websocket;

import com.vithey.chat.security.CurrentUser;
import com.vithey.chat.security.StompUser;
import com.vithey.chat.service.PresenceService;
import java.security.Principal;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

@Component
public class ChatWebSocketEventListener {

  private final PresenceService presenceService;

  public ChatWebSocketEventListener(PresenceService presenceService) {
    this.presenceService = presenceService;
  }

  @EventListener
  public void onConnect(SessionConnectedEvent event) {
    CurrentUser user = resolveCurrentUser(event.getUser());
    if (user != null) {
      presenceService.markOnline(user.userId());
    }
  }

  @EventListener
  public void onDisconnect(SessionDisconnectEvent event) {
    StompHeaderAccessor accessor = StompHeaderAccessor.wrap(event.getMessage());
    CurrentUser user = resolveCurrentUser(accessor.getUser());
    if (user != null) {
      presenceService.markOffline(user.userId());
    }
  }

  private CurrentUser resolveCurrentUser(Principal principal) {
    if (principal instanceof UsernamePasswordAuthenticationToken auth
        && auth.getPrincipal() instanceof StompUser stompUser) {
      return stompUser.currentUser();
    }
    return null;
  }
}
