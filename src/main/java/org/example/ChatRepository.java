package org.example;

import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArraySet;

public class ChatRepository {
  private static List<ChatMessage> repository = new LinkedList<>();
  private static CopyOnWriteArraySet<String> users = new CopyOnWriteArraySet<>();

  public static List<ChatMessage> getRepository() {
    return repository;
  }

  public static synchronized void addChat(ChatMessage chatMessage) {
    repository.add(chatMessage);
    if (repository.size() > 10) repository.remove(0);
  }

  public static CopyOnWriteArraySet<String> getUsers() {
    return users;
  }
}
