<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--@elvariable id="username" type="java.lang.String"--%>
<%--@elvariable id="chatRepository" type="java.util.List<org.example.ChatMessage>"--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>聊天室</title>
    <script src="https://code.jquery.com/jquery-3.5.0.js"
            integrity="sha256-r/AaFHrszJtwpe+tHyNi/XCfMxYpbsRg2Uqn0x3s2zc=" crossorigin="anonymous"></script>
    <script src="http://cdn.staticfile.org/moment.js/2.24.0/moment-with-locales.js"></script>
</head>
<body>
<h2>聊天室</h2>
<div id="chat-room-error">
    <div class="alert-header"><h3>Error</h3></div>
    <div class="alert-body" id="chat-room-error-body">An error occured.</div>
    <div class="alert-button">
        <button onclick="sendToHome();">OK</button>
    </div>
</div>
<div id="chat-room-waiting">
    <div class="alert-header"><h3>连接中...</h3></div>
    <div class="alert-body" id="chat-room-waiting-body">请等待...</div>
</div>
<div id="chat-room-message-show">
    <c:forEach items="${chatRepository}" var="chats">
        <div class="chat-room-username">${chats.username}发布于：${chats.timestamp}</div>
        <div class="chat-room-message">${chats.message}</div>
        <br/>
    </c:forEach>
</div>
<div id="chat-room-message-button">
    <input type="text" id="chat-room-message-text"/>
    <button id="chat-room-message-send" class="button" onclick="sendMessage();">发送</button>
    <button id="chat-room-message-disconnect" class="button" onclick="disconnect();">离线</button>
    <div id="chat-room-message-send-log"><i>消息不能为空</i></div>
</div>
<script type="text/javascript" lang="javascript">
    $(document).ready(function () {
        let error = $("#chat-room-error");
        let errorBody = $("#chat-room-error-body");
        let waiting = $("#chat-room-waiting");
        let waitingBody = $("#chat-room-waiting-body");
        let messageShow = $("#chat-room-message-show");
        let messageText = $("#chat-room-message-text");
        let messageSendLog = $("#chat-room-message-send-log");
        let encoder = new TextEncoder("utf-8");
        let decoder = new TextDecoder("utf-8");
        let server = null;

        String.prototype.encodeHTML = function () {
            return this.replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&apos;');
        }

        let log = function (username, message, timestamp) {
            messageShow
                .append($('<div>')
                    .addClass('chat-room-username')
                    .text((username === '${username}' ? '你' : username) + ' 发布于：' + timestamp.toLocaleString()))
                .append($('<div>')
                    .addClass('chat-room-message')
                    .text(message))
                .append($('<br/>'));
        }

        if (!("WebSocket" in window)) {
            errorBody.text('WebSocket are not supported in this browser. Try to update your browser to the latest version.');
            error.show();
            return;
        }

        messageSendLog.hide();
        error.hide();
        waiting.show();
        try {
            server = new WebSocket("ws://" + window.location.host + '<c:url value="/room/${username}"/>');
            server.binaryType = "arraybuffer";
            waiting.hide();
        } catch (e) {
            waiting.hide();
            errorBody.text(e);
            error.show();
            return;
        }

        server.onopen = function (event) {
            waiting.hide();
            log('${username}', '加入了聊天室', new Date());
        }

        server.onclose = function (event) {
            if (server != null) {
                log('${username}', '离开了聊天室', new Date());
            }
            server = null;
            if (!event.wasClean || event.code !== 1000) {
                errorBody.text('Code ' + event.code + ': ' + event.reason);
                error.show();
            }
        }

        server.onerror = function (event) {
            errorBody.text(event.data);
            error.show();
        }

        server.onmessage = function (event) {
            if (event.data instanceof ArrayBuffer) {
                let message = JSON.parse(decoder.decode(new Uint8Array(event.data)));
                log(message.username, message.message, moment.unix(message.timestamp).format('YYYY/MM/DD kk:mm:ss'));
            } else {
                errorBody.text('Unexpected data type [' + typeof event.data + '].');
                error.show();
            }
        }

        sendMessage = function () {
            if (server === null) {
                errorBody.text("未连接");
                error.show();
            } else {
                let text = messageText.val();
                if (text === "" || text.trim().length === 0) {
                    messageSendLog.show();
                    return;
                }
                messageSendLog.hide();
                let message = {
                    username: '${username}',
                    message: text,
                    timestamp: new Date()
                }
                try {
                    let json = JSON.stringify(message);
                    let array = encoder.encode(json);
                    server.send(array.buffer);
                    messageText.val('');
                } catch (e) {
                    errorBody.text(e);
                    error.show();
                }
            }
        }

        sendToHome = function () {
            let button = $('<input>').attr('type', 'submit');
            $('body').append($('<div>').append($('<form>').attr('method', 'GET').attr('action', '/ChatRoom').append(button)));
            button.click();
        }

        disconnect = function () {
            if (server !== null) {
                log('${username}', '离开了聊天室', new Date());
                server.close();
                server = null;
                sendToHome();
            }
        }

        window.onbeforeunload = disconnect;
    });
</script>
</body>
</html>
