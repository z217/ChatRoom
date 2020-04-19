package org.example;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "chatRoomServlet", urlPatterns = "/room")
public class ChatRoomServlet extends HttpServlet {

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    resp.sendRedirect("/ChatRoom");
  }

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp)
      throws ServletException, IOException {
    String username = req.getParameter("username");
    if (username == null || username.trim().length() == 0) {
      req.setAttribute("error", "empty");
      req.getRequestDispatcher("/index.jsp").forward(req, resp);
    } else if (!username.matches("^[0-9a-zA-z_]+$")) {
      req.setAttribute("error", "illegal");
      req.getRequestDispatcher("/index.jsp").forward(req, resp);
    } else if (ChatRepository.getUsers().contains(username)) {
      req.setAttribute("error", "duplicated");
      req.getRequestDispatcher("/index.jsp").forward(req, resp);
    } else {
      req.setAttribute("username", username);
      req.setAttribute("chatRepository", ChatRepository.getRepository());
      req.getRequestDispatcher("/WEB-INF/jsp/view/chatRoom/room.jsp").forward(req, resp);
    }
  }
}
