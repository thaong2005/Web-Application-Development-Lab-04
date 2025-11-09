<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.regex.*" %>
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
    </style>
</head>
<body>
    <h1>📚 Student Management System</h1>

    <!-- Search form -->
    <form action="list_students.jsp" method="GET" style="margin-bottom:16px;">
        <input type="text" name="keyword" placeholder="Search by name or code..." 
               value="<%= request.getParameter("keyword") != null ? request.getParameter("keyword") : "" %>"
               style="padding:8px; width:300px;" />
        <button type="submit" style="padding:8px 12px;">Search</button>
        <button type="button" style="padding:8px 12px;" onclick="window.location.href='list_students.jsp'">Clear</button>
    </form>

    <% if (request.getParameter("message") != null) { %>
        <div class="message success">
            <%= request.getParameter("message") %>
        </div>
    <% } %>
    
    <% if (request.getParameter("error") != null) { %>
        <div class="message error">
            <%= request.getParameter("error") %>
        </div>
    <% } %>
    
    <a href="add_student.jsp" class="btn">➕ Add New Student</a>
    
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
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        
        conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/student_management",
            "root",
            "1234567890"
        );

        String keyword = request.getParameter("keyword");
        if (keyword != null) keyword = keyword.trim();

        String sql;
        if (keyword != null && !keyword.isEmpty()) {
            // Use LIKE on both full_name and student_code (case-insensitive depending on DB collation)
            sql = "SELECT * FROM students WHERE full_name LIKE ? OR student_code LIKE ? ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            rs = pstmt.executeQuery();
        } else {
            sql = "SELECT * FROM students ORDER BY id DESC";
            pstmt = conn.prepareStatement(sql);
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
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
        </tbody>
    </table>
</body>
</html>
