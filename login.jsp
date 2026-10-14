<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSLV – Admin Login</title>
    <link rel="stylesheet" type="text/css" href="stylexv3.css">
</head>
<body>

<%
    String loginError = "";
    boolean loggedIn  = false;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String uname = request.getParameter("username");
        String upass = request.getParameter("password");

        String dbUrl  = System.getenv("DB_URL")  != null ? System.getenv("DB_URL")  : "jdbc:mysql://localhost:3306/feedbackdata";
        String dbUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
        String dbPass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "123654";

        Connection       con = null;
        PreparedStatement ps = null;
        ResultSet         rs = null;

        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        ps  = con.prepareStatement(
              "SELECT * FROM admin_users WHERE username = ? AND password = ?");
        ps.setString(1, uname);
        ps.setString(2, upass);
        rs  = ps.executeQuery();

        if (rs.next()) {
            loggedIn = true;
            session.setAttribute("admin", uname);
        } else {
            loginError = "Invalid username or password. Please try again.";
        }

        rs.close();
        ps.close();
        con.close();
    }

    if (loggedIn) {
        response.sendRedirect("indexv3.html");
        return;
    }
%>

<div class="page-wrapper auth-page">

    <!-- PSLV Logo -->
    <div class="site-logo">
        <span class="logo-name">PSLV</span>
        <span class="logo-full">Paramount Service Line Ventures</span>
    </div>

    <!-- Centered login card -->
    <div class="auth-center">
        <div class="glass-card auth-card genie-in">

<!--            <div class="auth-icon">&#128274;</div>-->
            <h2 class="section-title">Admin Login</h2>
            <p class="auth-sub">Sign in to access the portal</p>

            <% if (!loginError.equals("")) { %>
            <div class="error-msg">
                <span class="error-icon">&#9888;</span>
                <%= loginError %>
            </div>
            <% } %>

            <form action="login.jsp" method="post">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username"
                           placeholder="Enter your username" required autocomplete="off">
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password"
                           placeholder="Enter your password" required>
                </div>

                <div class="auth-btn-row">
                    <input type="submit" class="submit-btn" value="LOGIN">
                    <a href="register.jsp" class="submit-btn btn-secondary">
                        Register Account
                    </a>
                </div>
            </form>

        </div>
    </div>

</div>


</body>
</html>
