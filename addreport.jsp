<%@ page import="java.sql.*" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    String repId     = request.getParameter("id");
    String repTitle  = request.getParameter("title");
    String repAuthor = request.getParameter("author");

    if (repId == null || repTitle == null || repAuthor == null
        || repId.trim().equals("") || repTitle.trim().equals("") || repAuthor.trim().equals("")) {
        out.print("{\"success\":false,\"error\":\"All fields are required.\"}");
        return;
    }

    String dbUrl  = "jdbc:mysql://localhost:3306/REPORTS";
    String dbUser = "root";
    String dbPass = "123654";

    Connection        con = null;
    PreparedStatement ps  = null;

    Class.forName("com.mysql.cj.jdbc.Driver");
    con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

    /* Check if ID already exists */
    PreparedStatement chk   = con.prepareStatement("SELECT ID FROM REPORT_LIST WHERE ID = ?");
    chk.setString(1, repId.trim());
    ResultSet chkRs = chk.executeQuery();
    if (chkRs.next()) {
        chkRs.close();
        chk.close();
        con.close();
        out.print("{\"success\":false,\"error\":\"Report ID already exists. Use a different ID.\"}");
        return;
    }
    chkRs.close();
    chk.close();

    ps = con.prepareStatement("INSERT INTO REPORT_LIST (ID, TITLE, AUTHOR) VALUES (?, ?, ?)");
    ps.setString(1, repId.trim());
    ps.setString(2, repTitle.trim());
    ps.setString(3, repAuthor.trim());
    ps.executeUpdate();
    ps.close();
    con.close();

    out.print("{\"success\":true}");
%>
