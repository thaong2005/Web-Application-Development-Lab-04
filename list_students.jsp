<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.net.URLEncoder" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Student List</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 20px;
            background-color: #f5f5f5;
        }
        h1 { color: #333; }
        .message {
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 5px;
        }
        .success {
            background-color: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .error {
            background-color: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .btn {
            display: inline-block;
            padding: 10px 20px;
            margin-bottom: 20px;
            background-color: #007bff;
            color: white;
            text-decoration: none;
            border-radius: 5px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            background-color: white;
        }
        th {
            background-color: #007bff;
            color: white;
            padding: 12px;
            text-align: left;
        }
        td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        tr:hover { background-color: #f8f9fa; }
        .action-link {
            color: #007bff;
            text-decoration: none;
            margin-right: 10px;
        }
        .delete-link { color: #dc3545; }
        .table-responsive { overflow-x: auto; }

        .pagination { margin-top: 16px; }
        .pagination a, .pagination strong {
            display: inline-block;
            padding: 6px 10px;
            margin-right: 6px;
            text-decoration: none;
            border-radius: 4px;
            border: 1px solid #ddd;
            color: #007bff;
        }
        .pagination strong {
            background: #007bff;
            color: #fff;
            border-color: #007bff;
        }

        @media (max-width: 768px) {
            table { font-size: 12px; }
            th, td { padding: 5px; }
        }
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>

    <!-- Search form -->
    <form action="list_students.jsp" method="GET" style="margin-bottom:16px;" onsubmit="return submitForm(this);">
        <input type="text" name="keyword" placeholder="Search by name or code..." 
               value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>"
               style="padding:8px; width:300px;" />
        <button type="submit" style="padding:8px 12px;">Search</button>
        <a href="list_students.jsp" style="padding:8px 12px; margin-left:8px; text-decoration:none;">Clear</a>
    </form>
    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            ✓ <%= request.getParameter("message") %>
        </div>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            ✗ <%= request.getParameter("error") %>
        </div>
    <% } %>
    
    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    
    <div class="table-responsive">
    <table>
        <thead>
            <tr>
                <th>ID</th>
                <th>Student Code</th>
                <th>Full Name</th>
                <th>Email</th>
                <th>Major</th>
                <th>Created At</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement countPstmt = null;
    ResultSet countRs = null;
    int currentPage = 1;
    int recordsPerPage = 10;
    int totalRecords = 0;
    int totalPages = 0;
    String keyword = request.getParameter("keyword");
    if (keyword != null) keyword = keyword.trim();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "1234567890"
        );

        // Pagination params
        String pageParam = request.getParameter("page");
        try {
            if (pageParam != null) currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
        } catch (Exception e) { currentPage = 1; }

        // Get total records (with optional search filter)
        String countSql;
        if (keyword != null && !keyword.isEmpty()) {
            countSql = "SELECT COUNT(*) FROM students WHERE full_name LIKE ? OR student_code LIKE ?";
            countPstmt = conn.prepareStatement(countSql);
            countPstmt.setString(1, "%" + keyword + "%");
            countPstmt.setString(2, "%" + keyword + "%");
        } else {
            countSql = "SELECT COUNT(*) FROM students";
            countPstmt = conn.prepareStatement(countSql);
        }
        countRs = countPstmt.executeQuery();
        if (countRs.next()) totalRecords = countRs.getInt(1);
        totalPages = (int) Math.ceil((double) totalRecords / recordsPerPage);

        if (totalPages > 0 && currentPage > totalPages) currentPage = totalPages;
        int offset = (currentPage - 1) * recordsPerPage;

        // Prepare list query with LIMIT/OFFSET
        String sql;
        if (keyword != null && !keyword.isEmpty()) {
            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id DESC LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            pstmt.setInt(3, recordsPerPage);
            pstmt.setInt(4, offset);
            rs = pstmt.executeQuery();
        } else {
            sql = "SELECT * FROM students ORDER BY id DESC LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, recordsPerPage);
            pstmt.setInt(2, offset);
            rs = pstmt.executeQuery();
        }

        while (rs.next()) {
            int id = rs.getInt("id");
            String studentCode = rs.getString("student_code");
            String fullName = rs.getString("full_name");
            String email = rs.getString("email");
            String major = rs.getString("major");
            Timestamp createdAt = rs.getTimestamp("created_at");

            // Highlight keyword (bonus) in name and code
            String displayFullName = fullName != null ? fullName : "";
            String displayStudentCode = studentCode != null ? studentCode : "";
            if (keyword != null && !keyword.isEmpty()) {
                try {
                    String q = Pattern.quote(keyword);
                    displayFullName = displayFullName.replaceAll("(?i)" + q, "<mark>$0</mark>");
                    displayStudentCode = displayStudentCode.replaceAll("(?i)" + q, "<mark>$0</mark>");
                } catch (Exception e) {
                    // if regex fails, fall back to original values
                }
            }
%>
            <tr>
                <td><%= id %></td>
                <td><%= displayStudentCode %></td>
                <td><%= displayFullName %></td>
                <td><%= email != null ? email : "N/A" %></td>
                <td><%= major != null ? major : "N/A" %></td>
                <td><%= createdAt %></td>
                <td>
                    <a href="edit_student.jsp?id=<%= id %>" class="action-link">✏️ Edit</a>
                    <a href="delete_student.jsp?id=<%= id %>" 
                       class="action-link delete-link"
                       onclick="return confirm('Are you sure?')">🗑️ Delete</a>
                </td>
            </tr>
<%
        }
    } catch (ClassNotFoundException e) {
        out.println("<tr><td colspan='7'>Error: JDBC Driver not found!</td></tr>");
        e.printStackTrace();
    } catch (SQLException e) {
        out.println("<tr><td colspan='7'>Database Error: " + e.getMessage() + "</td></tr>");
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (countRs != null) countRs.close();
            if (countPstmt != null) countPstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
        </tbody>
    </table>
    </div>

    <div class="pagination">
    <%
        String baseParams = "";
        try {
            if (keyword != null && !keyword.isEmpty()) {
                baseParams = "keyword=" + URLEncoder.encode(keyword, "UTF-8") + "&";
            }
        } catch (Exception e) { baseParams = ""; }

        if (currentPage > 1) {
    %>
        <a href="list_students.jsp?<%= baseParams %>page=<%= currentPage - 1 %>">Previous</a>
    <% } %>
    <% for (int i = 1; i <= totalPages; i++) { %>
        <% if (i == currentPage) { %>
            <strong><%= i %></strong>
        <% } else { %>
            <a href="list_students.jsp?<%= baseParams %>page=<%= i %>"><%= i %></a>
        <% } %>
    <% } %>
    <% if (currentPage < totalPages) { %>
        <a href="list_students.jsp?<%= baseParams %>page=<%= currentPage + 1 %>">Next</a>
    <% } %>
    </div>

    <script>
        // Auto-hide messages after 3s
        setTimeout(function() {
            var messages = document.querySelectorAll('.message');
            messages.forEach(function(msg) {
                msg.style.display = 'none';
            });
        }, 3000);

        // Prevent double-submit and show processing state
        function submitForm(form) {
            var btn = form.querySelector('button[type="submit"]');
            if (btn) {
                btn.disabled = true;
                btn.textContent = 'Processing...';
            }
            return true;
        }
    </script>
</body>
</html>
