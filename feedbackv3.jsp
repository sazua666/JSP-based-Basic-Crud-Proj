<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSLV – Feedback</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;900&family=Playfair+Display:wght@700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="stylexv3.css">
</head>
<body>

<%
    boolean submitted = false;
    boolean dbError   = false;
    String  errMsg    = "";

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        String uName    = request.getParameter("name");
        String uCompany = request.getParameter("company");
        String uReport  = request.getParameter("report");

        String dbUrl  = System.getenv("DB_URL")  != null ? System.getenv("DB_URL")  : "jdbc:mysql://localhost:3306/feedbackdata";
        String dbUser = System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root";
        String dbPass = System.getenv("DB_PASS") != null ? System.getenv("DB_PASS") : "123654";

        Connection con  = null;
        PreparedStatement ps = null;

        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(dbUrl, dbUser, dbPass);
        ps  = con.prepareStatement(
                "INSERT INTO feedback (name, company, report) VALUES (?, ?, ?)");
        ps.setString(1, uName);
        ps.setString(2, uCompany);
        ps.setString(3, uReport);
        ps.executeUpdate();
        ps.close();
        con.close();
        submitted = true;
    }
%>

<div class="page-wrapper">

    <!-- PSLV Logo — top left -->
    <div class="site-logo">
        <span class="logo-name">PSLV</span>
        <span class="logo-full">Paramount Service Line Ventures</span>
    </div>

    <!-- Content Division -->
    <div class="content-div genie-in">

        <% if (submitted) { %>

        <!-- ── SUCCESS STATE ─────────────────────────────── -->
        <div class="glass-card success-card">
            <div class="success-icon">&#10003;</div>
            <h2 class="section-title">Feedback Submitted!</h2>
            <p class="success-msg">Thank you. Your feedback has been recorded successfully.</p>
            <a href="feedbackv3.jsp" class="submit-btn" style="text-decoration:none; display:inline-block; margin-top:18px;">
                Submit Another
            </a>
        </div>

        <% } else { %>

        <div class="glass-card">
            <h2 class="section-title">Feedback</h2>

            <form action="feedbackv3.jsp" method="post">
                <div class="form-group">
                    <label for="name">Name</label>
                    <input type="text" id="name" name="name"
                           placeholder="Your full name" required>
                </div>
                <div class="form-group">
                    <label for="company">Company Name</label>
                    <input type="text" id="company" name="company"
                           placeholder="Your company" required>
                </div>
                <div class="form-group">
                    <label for="report">Report of Interest</label>
                    <input type="text" id="report" name="report"
                           placeholder="Report title or ID" required>
                </div>
                <input type="submit" class="submit-btn" value="SUBMIT">
            </form>
        </div>

        <% } %>

    </div>

    <!-- Menu Division -->
    <div class="menu-div">
        <a href="feedbackv3.jsp" class="nav-link active">Feedback</a>
        <a href="reportsv3.jsp" class="nav-link">List of Reports</a>
        <a href="indexv3.html" class="nav-link">Home</a>
    </div>
</div>

<script>
document.querySelectorAll('.nav-link').forEach(link => {
    link.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href === 'feedbackv3.jsp') return;
        e.preventDefault();
        const content = document.querySelector('.content-div');
        content.classList.remove('genie-in');
        void content.offsetWidth;
        content.classList.add('genie-out');
        setTimeout(() => { window.location.href = href; }, 480);
    });
});
</script>
</body>
</html>
