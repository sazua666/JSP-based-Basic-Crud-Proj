<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PSLV – List of Reports</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;600;700;900&family=Playfair+Display:wght@700;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" type="text/css" href="stylexv3.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2canvas/1.4.1/html2canvas.min.js"></script>
</head>
<body>

<%
    /* ── Fetch all report data once, store in List ──────── */
    String dbUrl  = "jdbc:mysql://localhost:3306/your_database_name"; // Replace with your actual database URL
    String dbUser = "root"; // Replace with your actual database username
    String dbPass = "password"; // Replace with your actual database password

    /* Each record: String[]{id, title, author} */
    List<String[]> reportRows = new ArrayList<String[]>();

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection con  = DriverManager.getConnection(dbUrl, dbUser, dbPass);
    Statement  stmt = con.createStatement();
    ResultSet  rs   = stmt.executeQuery("SELECT * FROM REPORT_LIST");

    while (rs.next()) {
        reportRows.add(new String[]{
            rs.getString("ID"),
            rs.getString("TITLE"),
            rs.getString("AUTHOR")
        });
    }
    rs.close();
    stmt.close();
    con.close();

    /* Build JS JSON array from the list */
    StringBuilder jsArr = new StringBuilder("[");
    for (int i = 0; i < reportRows.size(); i++) {
        String[] r = reportRows.get(i);
        String safeTitle  = r[1].replace("\\","\\\\").replace("\"","\\\"").replace("'","\\'");
        String safeAuthor = r[2].replace("\\","\\\\").replace("\"","\\\"").replace("'","\\'");
        if (i > 0) jsArr.append(",");
        jsArr.append("{\"id\":\"").append(r[0])
             .append("\",\"title\":\"").append(safeTitle)
             .append("\",\"author\":\"").append(safeAuthor).append("\"}");
    }
    jsArr.append("]");
%>

<!-- ══ REMOVE DATA MODAL ════════════════════════════════════ -->
<div id="remove-overlay" class="modal-overlay" onclick="closeRemoveModal(event)">
    <div class="modal-card glass-card" id="remove-card">

        <button class="modal-close" onclick="closeRemoveModal(null,true)">&#10005;</button>

        <div class="auth-icon remove-icon">&#128465;</div>
        <h2 class="section-title">Remove a Report</h2>
        <p class="auth-sub">Select a record to permanently delete it from the database</p>

        <!-- Success state -->
        <div id="remove-success" style="display:none;">
            <div class="success-icon" style="margin:0 auto 12px;">&#10003;</div>
            <p class="success-msg">Report removed successfully!</p>
            <p class="success-msg" style="font-size:12px;margin-top:6px;opacity:0.7;">
                Click the refresh icon to see the updated table.
            </p>
        </div>

        <!-- Form -->
        <div id="remove-form-wrap">

            <div id="remove-error" class="error-msg" style="display:none;">
                <span class="error-icon">&#9888;</span>
                <span id="remove-error-text">Something went wrong.</span>
            </div>

            <!-- ID dropdown -->
            <div class="form-group">
                <label for="sel-id">Report ID</label>
                <div class="select-wrap">
                    <select id="sel-id" class="glass-select">
                        <option value="">-- Select Report ID --</option>
                        <% for (String[] r : reportRows) { %>
                        <option value="<%= r[0] %>"><%= r[0] %></option>
                        <% } %>
                    </select>
                    <span class="select-arrow">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5"
                             stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="6 9 12 15 18 9"/>
                        </svg>
                    </span>
                </div>
            </div>

            <!-- Title dropdown (auto-filled, read-only) -->
            <div class="form-group">
                <label for="sel-title">Title</label>
                <div class="select-wrap">
                    <select id="sel-title" class="glass-select" disabled>
                        <option value="">-- auto-filled --</option>
                        <% for (String[] r : reportRows) { %>
                        <option value="<%= r[1] %>"><%= r[1] %></option>
                        <% } %>
                    </select>
                    <span class="select-arrow">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5"
                             stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="6 9 12 15 18 9"/>
                        </svg>
                    </span>
                </div>
            </div>

            <!-- Author dropdown (auto-filled, read-only) -->
            <div class="form-group">
                <label for="sel-author">Author</label>
                <div class="select-wrap">
                    <select id="sel-author" class="glass-select" disabled>
                        <option value="">-- auto-filled --</option>
                        <% for (String[] r : reportRows) { %>
                        <option value="<%= r[2] %>"><%= r[2] %></option>
                        <% } %>
                    </select>
                    <span class="select-arrow">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                             stroke="currentColor" stroke-width="2.5"
                             stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="6 9 12 15 18 9"/>
                        </svg>
                    </span>
                </div>
            </div>

            <p class="remove-warning">
                &#9888;&nbsp; This action cannot be undone.
            </p>

            <button class="submit-btn remove-submit-btn" id="removeBtn" disabled
                    onclick="submitRemove()">
                Remove Data
            </button>

        </div>
    </div>
</div>

<!-- ══ MAIN PAGE ════════════════════════════════════════════ -->
<div class="page-wrapper">

    <!-- PSLV Logo -->
    <div class="site-logo">
        <span class="logo-name">PSLV</span>
        <span class="logo-full">Paramount Service Line Ventures</span>
    </div>

    <!-- Content Division -->
    <div class="content-div genie-in">

        <div class="glass-card reports-card">

            <!-- Card header: refresh icon + title -->
            <div class="reports-header">
                <button class="refresh-btn" id="refreshBtn" title="Refresh table"
                        onclick="refreshTable()">
                    <svg id="refresh-icon" width="15" height="15" viewBox="0 0 24 24"
                         fill="none" stroke="currentColor" stroke-width="2.5"
                         stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="23 4 23 10 17 10"/>
                        <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/>
                    </svg>
                </button>
                <h2 class="section-title" style="margin:0;">Reports</h2>
                <div style="width:32px;"></div><!-- spacer for symmetry -->
            </div>

            <!-- Table -->
            <div class="reports-wrapper" id="reportsTable">
                <table class="reports-table">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>TITLE</th>
                            <th>AUTHOR</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (String[] r : reportRows) { %>
                        <tr>
                            <td><span class="id-badge"><%= r[0] %></span></td>
                            <td><%= r[1] %></td>
                            <td><%= r[2] %></td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>

            <!-- Action buttons row: Remove (left) + Download (right) -->
            <div class="table-actions-row">

                <button class="remove-btn" onclick="openRemoveModal()">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2.5"
                         stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"/>
                        <path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/>
                        <path d="M10 11v6"/><path d="M14 11v6"/>
                        <path d="M9 6V4a1 1 0 0 1 1-1h4a1 1 0 0 1 1 1v2"/>
                    </svg>
                    Remove Data
                </button>

                <button class="download-btn" id="downloadBtn">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                         stroke="currentColor" stroke-width="2.5"
                         stroke-linecap="round" stroke-linejoin="round">
                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                        <polyline points="7 10 12 15 17 10"/>
                        <line x1="12" y1="15" x2="12" y2="3"/>
                    </svg>
                    Download Data
                </button>

            </div>
        </div>
    </div>

    <!-- Menu Division -->
    <div class="menu-div">
        <a href="feedbackv3.jsp" class="nav-link">Feedback</a>
        <a href="reportsv3.jsp" class="nav-link active">List of Reports</a>
        <a href="indexv3.html" class="nav-link">Home</a>
    </div>
</div>

<script>
/* ── Report data from server ─────────────────────────────── */
var reportData = <%= jsArr.toString() %>;

/* ── REFRESH TABLE ──────────────────────────────────────── */
function refreshTable() {
    var icon = document.getElementById('refresh-icon');
    icon.classList.add('spin');
    setTimeout(function () { window.location.reload(); }, 400);
}

/* ── REMOVE MODAL ───────────────────────────────────────── */
function openRemoveModal() {
    var overlay = document.getElementById('remove-overlay');
    var card    = document.getElementById('remove-card');
    overlay.classList.add('modal-visible');
    card.classList.add('modal-card-in');
    document.body.style.overflow = 'hidden';
}

function closeRemoveModal(e, force) {
    if (!force && e && e.target !== document.getElementById('remove-overlay')) return;
    var card = document.getElementById('remove-card');
    card.classList.remove('modal-card-in');
    card.classList.add('modal-card-out');
    setTimeout(function () {
        document.getElementById('remove-overlay').classList.remove('modal-visible');
        card.classList.remove('modal-card-out');
        /* reset */
        document.getElementById('sel-id').value     = '';
        document.getElementById('sel-title').value  = '';
        document.getElementById('sel-author').value = '';
        document.getElementById('removeBtn').disabled = true;
        document.getElementById('remove-success').style.display   = 'none';
        document.getElementById('remove-form-wrap').style.display = '';
        document.getElementById('remove-error').style.display     = 'none';
        document.body.style.overflow = '';
    }, 350);
}

/* Auto-fill Title & Author when ID is selected */
document.getElementById('sel-id').addEventListener('change', function () {
    var id     = this.value;
    var selTit = document.getElementById('sel-title');
    var selAut = document.getElementById('sel-author');
    var removeBtn = document.getElementById('removeBtn');

    if (!id) {
        selTit.value  = '';
        selAut.value  = '';
        removeBtn.disabled = true;
        return;
    }

    var found = null;
    for (var i = 0; i < reportData.length; i++) {
        if (reportData[i].id === id) { found = reportData[i]; break; }
    }
    if (found) {
        /* Match the option value in the select elements */
        for (var j = 0; j < selTit.options.length; j++) {
            if (selTit.options[j].value === found.title) {
                selTit.selectedIndex = j; break;
            }
        }
        for (var k = 0; k < selAut.options.length; k++) {
            if (selAut.options[k].value === found.author) {
                selAut.selectedIndex = k; break;
            }
        }
        removeBtn.disabled = false;
    }
});

/* Submit remove via fetch */
function submitRemove() {
    var id      = document.getElementById('sel-id').value;
    var btn     = document.getElementById('removeBtn');
    var errDiv  = document.getElementById('remove-error');
    var errText = document.getElementById('remove-error-text');

    if (!id) return;

    btn.textContent = 'Removing...';
    btn.disabled    = true;
    errDiv.style.display = 'none';

    var params = new URLSearchParams();
    params.append('id', id);

    fetch('removereport.jsp', { method: 'POST', body: params })
    .then(function (res) { return res.json(); })
    .then(function (data) {
        if (data.success) {
            document.getElementById('remove-form-wrap').style.display = 'none';
            document.getElementById('remove-success').style.display   = '';
            setTimeout(function () { closeRemoveModal(null, true); }, 1800);
        } else {
            errText.textContent  = data.error || 'Failed to remove. Please try again.';
            errDiv.style.display = 'flex';
            btn.textContent  = 'Remove Data';
            btn.disabled     = false;
        }
    })
    .catch(function () {
        errText.textContent  = 'Connection error. Please try again.';
        errDiv.style.display = 'flex';
        btn.textContent  = 'Remove Data';
        btn.disabled     = false;
    });
}

/* Close on Escape */
document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') closeRemoveModal(null, true);
});

/* ── DOWNLOAD ────────────────────────────────────────────── */
document.getElementById('downloadBtn').addEventListener('click', function () {
    var btn = this;
    btn.textContent = 'Capturing...';
    btn.disabled = true;

    var original = document.getElementById('reportsTable');
    var clone    = original.cloneNode(true);

    clone.style.cssText = 'position:fixed;top:-9999px;left:-9999px;width:'
        + original.offsetWidth + 'px;background:#ffffff;padding:24px;'
        + 'border-radius:12px;font-family:Outfit,sans-serif;'
        + 'box-shadow:none;backdrop-filter:none;z-index:-1;';

    var table = clone.querySelector('table');
    if (table) table.style.cssText = 'width:100%;border-collapse:collapse;font-size:15px;font-family:Outfit,sans-serif;';

    var ths = clone.querySelectorAll('th');
    ths.forEach(function (th) {
        th.style.cssText = 'background:#1a4dcc;color:#ffffff;padding:12px 18px;text-align:left;font-size:13px;letter-spacing:0.05em;border:1px solid #1a4dcc;';
    });

    var tds = clone.querySelectorAll('td');
    tds.forEach(function (td, i) {
        var row = Math.floor(i / ths.length);
        var bg  = (row % 2 === 0) ? '#f0f6ff' : '#ffffff';
        td.style.cssText = 'background:' + bg + ';color:#0d2e85;padding:11px 18px;font-size:14px;border:1px solid #dbeafe;';
    });

    clone.querySelectorAll('.id-badge').forEach(function (b) {
        b.style.cssText = 'background:#dbeafe;color:#0d2e85;padding:3px 10px;border-radius:20px;font-weight:700;font-size:12px;border:1px solid #93c5fd;';
    });

    document.body.appendChild(clone);
    html2canvas(clone, { backgroundColor:'#ffffff', scale:3, useCORS:true, logging:false })
    .then(function (canvas) {
        document.body.removeChild(clone);
        var link = document.createElement('a');
        link.download = 'PSLV_Reports_' + new Date().toISOString().slice(0,10) + '.png';
        link.href = canvas.toDataURL('image/png');
        link.click();
        btn.innerHTML = 'Download Data';
        btn.disabled = false;
    });
});

/* ── GENIE NAVIGATION ───────────────────────────────────── */
document.querySelectorAll('.nav-link').forEach(function (link) {
    link.addEventListener('click', function (e) {
        var href = this.getAttribute('href');
        if (href === 'reportsv3.jsp') return;
        e.preventDefault();
        var content = document.querySelector('.content-div');
        content.classList.remove('genie-in');
        void content.offsetWidth;
        content.classList.add('genie-out');
        setTimeout(function () { window.location.href = href; }, 480);
    });
});
</script>
</body>
</html>
