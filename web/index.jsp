<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--@elvariable id="username" type="java.util.String"--%>
<%--@elvariable id="error" type="java.util.String"--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>聊天室</title>
    <script src="https://code.jquery.com/jquery-3.5.0.js"
            integrity="sha256-r/AaFHrszJtwpe+tHyNi/XCfMxYpbsRg2Uqn0x3s2zc=" crossorigin="anonymous"></script>
</head>
<body>
<h2>聊天室</h2>
<form method="POST" action="<c:url value="/room"/>">
    Username: <input type="text" name="username"/><br/>
    <c:choose>
        <c:when test="${error == 'empty'}"><i>用户名不能为空</i></c:when>
        <c:when test="${error == 'illegal'}"><i>用户名只能包含数字、字母及下划线</i></c:when>
        <c:when test="${error == 'duplicated'}"><i>用户名重复</i></c:when>
        <c:otherwise>&nbsp;</c:otherwise>
    </c:choose><br/>
    <input type="submit" value="加入"/>
</form>
</body>
</html>
