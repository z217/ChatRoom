package org.example;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.time.OffsetDateTime;
import java.util.concurrent.CopyOnWriteArraySet;

@ServerEndpoint(
    value = "/room/{username}",
    encoders = ChatMessageCodec.class,
    decoders = ChatMessageCodec.class)
public class ChatRoomServer {
  private static CopyOnWriteArraySet<Session> sessions = new CopyOnWriteArraySet<>();

  @OnOpen
  public void onOpen(Session session, @PathParam("username") String username) {
    ChatRepository.getUsers().add(username);
    ChatMessage chatMessage = new ChatMessage(username, "加入了聊天室", OffsetDateTime.now());
    try {
      for (Session s : sessions) {
        if (s.isOpen()) s.getBasicRemote().sendObject(chatMessage);
      }
    } catch (IOException | EncodeException e) {
      onError(session, e);
    }
    sessions.add(session);
    session.getUserProperties().put("username", username);
  }

  @OnMessage
  public void onMessage(Session session, ChatMessage chatMessage) {
    if (chatMessage != null) {
      ChatRepository.addChat(chatMessage);
      try {
        for (Session s : sessions) {
          if (s.isOpen()) s.getBasicRemote().sendObject(chatMessage);
        }
      } catch (IOException | EncodeException e) {
        onError(session, e);
      }
    }
  }

  @OnError
  public void onError(Session session, Throwable e) {
    String username = (String) session.getUserProperties().get("username");
    ChatMessage chatMessage = new ChatMessage(username, "因错误而断开了连接", OffsetDateTime.now());
    try {
      for (Session s : sessions)
        if (s != session && s.isOpen()) {
          s.getBasicRemote().sendObject(chatMessage);
        }
    } catch (IOException | EncodeException ignore) {
    } finally {
      try {
        session.close(new CloseReason(CloseReason.CloseCodes.UNEXPECTED_CONDITION, e.toString()));
      } catch (IOException ignore) {
      }
    }
  }

  @OnClose
  public void onClose(Session session, CloseReason closeReason) {
    if (closeReason.getCloseCode() == CloseReason.CloseCodes.NORMAL_CLOSURE) {
      sessions.remove(session);
      String username = (String) session.getUserProperties().get("username");
      ChatRepository.getUsers().remove(username);
      ChatMessage chatMessage =
          new ChatMessage(username, username + "离开了聊天室", OffsetDateTime.now());
      try {
        for (Session s : sessions) if (s.isOpen()) s.getBasicRemote().sendObject(chatMessage);
      } catch (IOException | EncodeException e) {
        onError(session, e);
      }
    }
  }
}
