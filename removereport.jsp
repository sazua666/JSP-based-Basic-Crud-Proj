<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    String repId = request.getParameter("id");

    if (repId == null || repId.trim().equals("")) {
        out.print("{\"success\":false,\"error\":\"No report selected.\"}");
        return;
    }

    String dbUrl  = "jdbc:mysql://localhost:3306/REPORTS";
    String dbUser = "root";
    String dbPass = "123654";

    Connection        con = null;
    PreparedStatement ps  = null;

    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
    ps  = con.prepareStatement("DELETE FROM REPORT_LIST WHERE ID = ?");
    ps.setString(1, repId.trim());
    int rows = ps.executeUpdate();
    ps.close();
    con.close();

    if (rows > 0) {
        out.print("{\"success\":true}");
    } else {
        out.print("{\"success\":false,\"error\":\"Record not found in database.\"}");
    }
%>
