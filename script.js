// Student Management System

// Get DOM elements
const studentForm = document.getElementById('student-form');
const studentIdInput = document.getElementById('student-id');
const studentNameInput = document.getElementById('student-name');
const studentEmailInput = document.getElementById('student-email');
const studentAgeInput = document.getElementById('student-age');
const studentMajorInput = document.getElementById('student-major');
const studentList = document.getElementById('student-list');
const formTitle = document.getElementById('form-title');
const submitBtn = document.getElementById('submit-btn');
const cancelBtn = document.getElementById('cancel-btn');
const searchInput = document.getElementById('search-input');

// Initialize students array from localStorage
let students = JSON.parse(localStorage.getItem('students')) || [];

// Initialize the app
function init() {
    renderStudents();
    setupEventListeners();
}

// Setup event listeners
function setupEventListeners() {
    studentForm.addEventListener('submit', handleSubmit);
    cancelBtn.addEventListener('click', resetForm);
    searchInput.addEventListener('input', handleSearch);
}

// Handle form submission
function handleSubmit(e) {
    e.preventDefault();
    
    const studentId = studentIdInput.value;
    const student = {
        id: studentId || Date.now().toString(),
        name: studentNameInput.value.trim(),
        email: studentEmailInput.value.trim(),
        age: parseInt(studentAgeInput.value),
        major: studentMajorInput.value.trim()
    };
    
    if (studentId) {
        // Update existing student
        updateStudent(student);
    } else {
        // Add new student
        addStudent(student);
    }
    
    resetForm();
}

// Add a new student
function addStudent(student) {
    students.push(student);
    saveToLocalStorage();
    renderStudents();
    showNotification('Student added successfully!', 'success');
}

// Update an existing student
function updateStudent(updatedStudent) {
    const index = students.findIndex(s => s.id === updatedStudent.id);
    if (index !== -1) {
        students[index] = updatedStudent;
        saveToLocalStorage();
        renderStudents();
        showNotification('Student updated successfully!', 'success');
    }
}

// Delete a student
function deleteStudent(id) {
    if (confirm('Are you sure you want to delete this student?')) {
        students = students.filter(s => s.id !== id);
        saveToLocalStorage();
        renderStudents();
        showNotification('Student deleted successfully!', 'success');
    }
}

// Edit a student
function editStudent(id) {
    const student = students.find(s => s.id === id);
    if (student) {
        studentIdInput.value = student.id;
        studentNameInput.value = student.name;
        studentEmailInput.value = student.email;
        studentAgeInput.value = student.age;
        studentMajorInput.value = student.major;
        
        formTitle.textContent = 'Edit Student';
        submitBtn.textContent = 'Update Student';
        cancelBtn.style.display = 'inline-block';
        
        // Scroll to form
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }
}

// Reset form to initial state
function resetForm() {
    studentForm.reset();
    studentIdInput.value = '';
    formTitle.textContent = 'Add New Student';
    submitBtn.textContent = 'Add Student';
    cancelBtn.style.display = 'none';
}

// Handle search functionality
function handleSearch(e) {
    const searchTerm = e.target.value.toLowerCase().trim();
    
    if (searchTerm === '') {
        renderStudents();
    } else {
        const filteredStudents = students.filter(student => 
            student.name.toLowerCase().includes(searchTerm) ||
            student.email.toLowerCase().includes(searchTerm) ||
            student.major.toLowerCase().includes(searchTerm)
        );
        renderStudents(filteredStudents);
    }
}

// Render students to the DOM
function renderStudents(studentsToRender = students) {
    if (studentsToRender.length === 0) {
        studentList.innerHTML = '<div class="empty-message">No students found. Add your first student!</div>';
        return;
    }
    
    studentList.innerHTML = studentsToRender.map(student => `
        <div class="student-card" data-id="${student.id}">
            <div class="student-info">
                <p><strong>Name:</strong> ${escapeHtml(student.name)}</p>
                <p><strong>Email:</strong> ${escapeHtml(student.email)}</p>
                <p><strong>Age:</strong> ${student.age}</p>
                <p><strong>Major:</strong> ${escapeHtml(student.major)}</p>
            </div>
            <div class="student-actions">
                <button class="btn btn-edit" onclick="editStudent('${student.id}')">Edit</button>
                <button class="btn btn-delete" onclick="deleteStudent('${student.id}')">Delete</button>
            </div>
        </div>
    `).join('');
}

// Save students to localStorage
function saveToLocalStorage() {
    localStorage.setItem('students', JSON.stringify(students));
}

// Show notification (simple implementation)
function showNotification(message, type) {
    // Create notification element
    const notification = document.createElement('div');
    notification.textContent = message;
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        padding: 15px 25px;
        background: ${type === 'success' ? '#28a745' : '#dc3545'};
        color: white;
        border-radius: 5px;
        box-shadow: 0 5px 15px rgba(0,0,0,0.3);
        z-index: 1000;
        animation: slideIn 0.3s ease-out;
    `;
    
    document.body.appendChild(notification);
    
    // Remove notification after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease-out';
        setTimeout(() => notification.remove(), 300);
    }, 3000);
}

// Escape HTML to prevent XSS
function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Add CSS animation for notifications
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from {
            transform: translateX(400px);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOut {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(400px);
            opacity: 0;
        }
    }
`;
document.head.appendChild(style);

// Initialize the app when DOM is loaded
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
