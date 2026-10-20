<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSLV – Register Account</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;900&family=Playfair+Display:wght@700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="stylexv3.css">
</head>
<body>

<%
    boolean registered  = false;
    String  registerErr = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String newUser = request.getParameter("username");
        String newPass = request.getParameter("password");
        String confPass= request.getParameter("confirm_password");

        if (!newPass.equals(confPass)) {
            registerErr = "Passwords do not match. Please try again.";
        } else {
            String dbUrl  = "jdbc:mysql://localhost:3306/feedbackdata";
            String dbUser = "root";
            String dbPass = "123654";

            Connection        con = null;
            PreparedStatement ps  = null;

            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            /* Check if username already exists */
            PreparedStatement chk = con.prepareStatement(
                "SELECT id FROM admin_users WHERE username = ?");
            chk.setString(1, newUser);
            ResultSet chkRs = chk.executeQuery();

            if (chkRs.next()) {
                registerErr = "Username already exists. Please choose another.";
                chkRs.close();
                chk.close();
                con.close();
            } else {
                chkRs.close();
                chk.close();

                ps = con.prepareStatement(
                     "INSERT INTO admin_users (username, password) VALUES (?, ?)");
                ps.setString(1, newUser);
                ps.setString(2, newPass);
                ps.executeUpdate();
                ps.close();
                con.close();
                registered = true;
            }
        }
    }
%>

<div class="page-wrapper auth-page">

    <!-- PSLV Logo -->
    <div class="site-logo">
        <span class="logo-name">PSLV</span>
        <span class="logo-full">Paramount Service Line Ventures</span>
    </div>

    <div class="auth-center">

        <% if (registered) { %>

        <!-- ── SUCCESS STATE ──────────────────────────── -->
        <div class="glass-card auth-card success-card genie-in">
            <div class="success-icon">&#10003;</div>
            <h2 class="section-title">Registered!</h2>
            <p class="success-msg">Your admin account has been created successfully.</p>
            <p class="success-msg" style="margin-top:6px; font-size:13px; opacity:0.75;">
                You can now log in with your credentials.
            </p>

            <!-- Countdown redirect button — unclickable -->
            <button class="submit-btn countdown-btn" id="countdownBtn" disabled>
                Redirecting you in 3s...
            </button>
        </div>

        <script>
        var count = 3;
        var btn   = document.getElementById('countdownBtn');
        var timer = setInterval(function () {
            count--;
            if (count <= 0) {
                clearInterval(timer);
                window.location.href = 'login.jsp';
            } else {
                btn.textContent = 'Redirecting you in ' + count + 's...';
            }
        }, 1000);
        </script>

        <% } else { %>

        <!-- ── REGISTER FORM ───────────────────────────── -->
        <div class="glass-card auth-card genie-in">

            <div class="auth-icon">&#128100;</div>
            <h2 class="section-title">Create Account</h2>
            <p class="auth-sub">Register a new admin account</p>

            <% if (!registerErr.equals("")) { %>
            <div class="error-msg">
                <span class="error-icon">&#9888;</span>
                <%= registerErr %>
            </div>
            <% } %>

            <form action="register.jsp" method="post">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input type="text" id="username" name="username"
                           placeholder="Choose a username" required autocomplete="off">
                </div>
                <div class="form-group">
                    <label for="password">Password</label>
                    <input type="password" id="password" name="password"
                           placeholder="Choose a password" required>
                </div>
                <div class="form-group">
                    <label for="confirm_password">Confirm Password</label>
                    <input type="password" id="confirm_password" name="confirm_password"
                           placeholder="Re-enter your password" required>
                </div>

                <div class="auth-btn-row">
                    <input type="submit" class="submit-btn" value="REGISTER">
                    <a href="login.jsp" class="submit-btn btn-secondary">
                        Back to Login
                    </a>
                </div>
            </form>

        </div>

        <% } %>

    </div>

</div>

</body>
</html>
