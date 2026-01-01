// 全局变量
let currentUser = null;
let currentPage = {
    books: 0,
    users: 0,
    borrows: 0
};
let pageSize = 10;

// API基础URL
const API_BASE = '/api';

// 页面加载完成后初始化
document.addEventListener('DOMContentLoaded', function() {
    // 检查是否已登录
    const savedUser = localStorage.getItem('currentUser');
    if (savedUser) {
        currentUser = JSON.parse(savedUser);
        showMainSystem();
    }
    
    // 绑定登录表单事件
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    document.getElementById('registerForm').addEventListener('submit', handleRegister);
    document.getElementById('addBookForm').addEventListener('submit', handleAddBook);
    document.getElementById('addUserForm').addEventListener('submit', handleAddUser);
    document.getElementById('borrowBookForm').addEventListener('submit', handleBorrowBook);
});

// 登录处理
async function handleLogin(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData);
    
    try {
        const response = await fetch(`${API_BASE}/auth/login`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            currentUser = result;
            localStorage.setItem('currentUser', JSON.stringify(currentUser));
            showAlert('loginAlert', '登录成功！', 'success');
            setTimeout(() => {
                showMainSystem();
            }, 1000);
        } else {
            showAlert('loginAlert', result.message || '登录失败', 'danger');
        }
    } catch (error) {
        showAlert('loginAlert', '网络错误: ' + error.message, 'danger');
    }
}

// 注册处理
async function handleRegister(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData);
    
    try {
        const response = await fetch(`${API_BASE}/auth/register`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        const result = await response.json();
        
        if (response.ok) {
            showAlert('registerAlert', '注册成功！请登录', 'success');
            setTimeout(() => {
                showLogin();
            }, 1500);
        } else {
            showAlert('registerAlert', result.message || '注册失败', 'danger');
        }
    } catch (error) {
        showAlert('registerAlert', '网络错误: ' + error.message, 'danger');
    }
}

// 添加图书
async function handleAddBook(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData);
    
    // 转换数值类型
    data.totalCopies = parseInt(data.totalCopies);
    data.availableCopies = data.totalCopies; // 初始时可借数量等于总数量
    if (data.publishYear) data.publishYear = parseInt(data.publishYear);
    if (data.price) data.price = parseFloat(data.price);
    
    try {
        const response = await fetch(`${API_BASE}/books`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            closeModal('addBookModal');
            showMessage('图书添加成功！', 'success');
            loadBooks();
            e.target.reset();
        } else {
            const error = await response.json();
            showMessage(error.message || '添加失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 添加用户
async function handleAddUser(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData);
    
    try {
        const response = await fetch(`${API_BASE}/users`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        if (response.ok) {
            closeModal('addUserModal');
            showMessage('用户添加成功！', 'success');
            loadUsers();
            e.target.reset();
        } else {
            const error = await response.json();
            showMessage(error.message || '添加失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 借阅图书
async function handleBorrowBook(e) {
    e.preventDefault();
    const formData = new FormData(e.target);
    const userId = parseInt(formData.get('userId'));
    const bookId = parseInt(formData.get('bookId'));
    
    try {
        const response = await fetch(`${API_BASE}/borrow-records/borrow?userId=${userId}&bookId=${bookId}`, {
            method: 'POST'
        });
        
        if (response.ok) {
            closeModal('borrowBookModal');
            showMessage('借阅成功！', 'success');
            loadBorrows();
            loadDashboard();
            e.target.reset();
        } else {
            const error = await response.json();
            showMessage(error.message || '借阅失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 显示主系统
function showMainSystem() {
    document.getElementById('loginPage').classList.add('hidden');
    document.getElementById('registerPage').classList.add('hidden');
    document.getElementById('mainSystem').classList.remove('hidden');
    
    loadDashboard();
}

// 显示登录页面
function showLogin() {
    document.getElementById('loginPage').classList.remove('hidden');
    document.getElementById('registerPage').classList.add('hidden');
    document.getElementById('mainSystem').classList.add('hidden');
    clearAlert('loginAlert');
    clearAlert('registerAlert');
}

// 显示注册页面
function showRegister() {
    document.getElementById('loginPage').classList.add('hidden');
    document.getElementById('registerPage').classList.remove('hidden');
    document.getElementById('mainSystem').classList.add('hidden');
    clearAlert('loginAlert');
    clearAlert('registerAlert');
}

// 退出登录
function logout() {
    currentUser = null;
    localStorage.removeItem('currentUser');
    showLogin();
}

// 显示指定区域
function showSection(sectionId) {
    // 隐藏所有区域
    document.querySelectorAll('.section').forEach(section => {
        section.classList.remove('active');
    });
    
    // 移除所有导航按钮的active状态
    document.querySelectorAll('.nav-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    // 显示指定区域
    document.getElementById(sectionId).classList.add('active');
    
    // 激活对应的导航按钮
    event.target.classList.add('active');
    
    // 加载对应的数据
    switch(sectionId) {
        case 'dashboard':
            loadDashboard();
            break;
        case 'books':
            loadBooks();
            break;
        case 'users':
            loadUsers();
            break;
        case 'borrows':
            loadBorrows();
            break;
    }
}

// 加载系统概览数据
async function loadDashboard() {
    try {
        // 获取图书统计
        const booksResponse = await fetch(`${API_BASE}/books`);
        if (booksResponse.ok) {
            const booksData = await booksResponse.json();
            document.getElementById('totalBooks').textContent = booksData.totalElements || 0;
        }
        
        // 获取可借图书
        const availableResponse = await fetch(`${API_BASE}/books/available`);
        if (availableResponse.ok) {
            const availableBooks = await availableResponse.json();
            document.getElementById('availableBooks').textContent = availableBooks.length;
        }
        
        // 获取用户统计
        const usersResponse = await fetch(`${API_BASE}/users`);
        if (usersResponse.ok) {
            const usersData = await usersResponse.json();
            document.getElementById('totalUsers').textContent = usersData.totalElements || 0;
        }
        
        // 获取借阅中图书
        const borrowsResponse = await fetch(`${API_BASE}/borrow-records/status/BORROWED`);
        if (borrowsResponse.ok) {
            const borrowingBooks = await borrowsResponse.json();
            document.getElementById('borrowingBooks').textContent = borrowingBooks.length;
        }
    } catch (error) {
        console.error('加载系统概览失败:', error);
    }
}

// 加载图书列表
async function loadBooks(page = 0) {
    currentPage.books = page;
    try {
        const response = await fetch(`${API_BASE}/books?page=${page}&size=${pageSize}`);
        if (response.ok) {
            const data = await response.json();
            displayBooks(data.content);
            renderPagination('booksPagination', data.totalPages, page, loadBooks);
        }
    } catch (error) {
        showMessage('加载图书失败: ' + error.message, 'danger');
    }
}

// 显示图书列表
function displayBooks(books) {
    const tbody = document.getElementById('booksTableBody');
    tbody.innerHTML = '';
    
    books.forEach(book => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${book.id}</td>
            <td>${book.isbn}</td>
            <td>${book.title}</td>
            <td>${book.author}</td>
            <td>${book.publisher}</td>
            <td>${book.category}</td>
            <td>${book.totalCopies}</td>
            <td>${book.availableCopies}</td>
            <td>${book.location || '-'}</td>
            <td>
                ${book.availableCopies > 0 ? 
                    `<button onclick="showBorrowModal(${book.id})" class="btn btn-success btn-sm">借阅</button>` : 
                    '<span style="color: #999;">无库存</span>'
                }
                <button onclick="deleteBook(${book.id})" class="btn btn-danger btn-sm">删除</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

// 搜索图书
async function searchBooks(page = 0) {
    const keyword = document.getElementById('bookSearch').value.trim();
    if (!keyword) {
        loadBooks();
        return;
    }
    
    currentPage.books = page;
    try {
        const response = await fetch(`${API_BASE}/books/search?keyword=${encodeURIComponent(keyword)}&page=${page}&size=${pageSize}`);
        if (response.ok) {
            const data = await response.json();
            displayBooks(data.content);
            renderPagination('booksPagination', data.totalPages, page, (p) => searchBooks(p));
        }
    } catch (error) {
        showMessage('搜索失败: ' + error.message, 'danger');
    }
}

// 删除图书
async function deleteBook(id) {
    if (!confirm('确定要删除这本图书吗？')) return;
    
    try {
        const response = await fetch(`${API_BASE}/books/${id}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            showMessage('图书删除成功！', 'success');
            loadBooks();
        } else {
            showMessage('删除失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 加载用户列表
async function loadUsers(page = 0) {
    currentPage.users = page;
    try {
        const response = await fetch(`${API_BASE}/users?page=${page}&size=${pageSize}`);
        if (response.ok) {
            const data = await response.json();
            displayUsers(data.content);
            renderPagination('usersPagination', data.totalPages, page, loadUsers);
        }
    } catch (error) {
        showMessage('加载用户失败: ' + error.message, 'danger');
    }
}

// 显示用户列表
function displayUsers(users) {
    const tbody = document.getElementById('usersTableBody');
    tbody.innerHTML = '';
    
    users.forEach(user => {
        const row = document.createElement('tr');
        row.innerHTML = `
            <td>${user.id}</td>
            <td>${user.username}</td>
            <td>${user.realName}</td>
            <td>${user.email}</td>
            <td>${user.phone || '-'}</td>
            <td>${user.userType === 'ADMIN' ? '管理员' : '读者'}</td>
            <td>${user.status === 1 ? '正常' : '禁用'}</td>
            <td>${user.borrowCount}/${user.maxBorrowLimit}</td>
            <td>
                <button onclick="toggleUserStatus(${user.id}, ${user.status})" class="btn btn-warning btn-sm">
                    ${user.status === 1 ? '禁用' : '启用'}
                </button>
                <button onclick="deleteUser(${user.id})" class="btn btn-danger btn-sm">删除</button>
            </td>
        `;
        tbody.appendChild(row);
    });
}

// 搜索用户
async function searchUsers(page = 0) {
    const keyword = document.getElementById('userSearch').value.trim();
    // 这里简化处理，实际应该根据用户类型分别搜索
    loadUsers(page);
}

// 删除用户
async function deleteUser(id) {
    if (!confirm('确定要删除这个用户吗？')) return;
    
    try {
        const response = await fetch(`${API_BASE}/users/${id}`, {
            method: 'DELETE'
        });
        
        if (response.ok) {
            showMessage('用户删除成功！', 'success');
            loadUsers();
        } else {
            showMessage('删除失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 切换用户状态
async function toggleUserStatus(id, currentStatus) {
    // 这里简化处理，实际应该更新用户状态
    showMessage('功能开发中...', 'warning');
}

// 加载借阅记录
async function loadBorrows(page = 0) {
    currentPage.borrows = page;
    try {
        const response = await fetch(`${API_BASE}/borrow-records?page=${page}&size=${pageSize}`);
        if (response.ok) {
            const data = await response.json();
            displayBorrows(data.content);
            renderPagination('borrowsPagination', data.totalPages, page, loadBorrows);
        }
    } catch (error) {
        showMessage('加载借阅记录失败: ' + error.message, 'danger');
    }
}

// 显示借阅记录
function displayBorrows(records) {
    const tbody = document.getElementById('borrowsTableBody');
    tbody.innerHTML = '';
    
    records.forEach(record => {
        const row = document.createElement('tr');
        const statusText = getStatusText(record.status);
        const statusClass = getStatusClass(record.status);
        
        row.innerHTML = `
            <td>${record.id}</td>
            <td>${record.user ? record.user.realName : '未知用户'}</td>
            <td>${record.book ? record.book.title : '未知图书'}</td>
            <td>${record.borrowDate}</td>
            <td>${record.dueDate}</td>
            <td><span class="${statusClass}">${statusText}</span></td>
            <td>${record.fine || '-'}</td>
            <td>
                ${record.status === 'BORROWED' ? 
                    `<button onclick="returnBook(${record.id})" class="btn btn-success btn-sm">归还</button>
                     <button onclick="renewBook(${record.id})" class="btn btn-warning btn-sm">续借</button>` : 
                    ''
                }
                ${record.status === 'OVERDUE' ? 
                    `<button onclick="returnBook(${record.id})" class="btn btn-danger btn-sm">归还(逾期)</button>` : 
                    ''
                }
            </td>
        `;
        tbody.appendChild(row);
    });
}

// 获取状态文本
function getStatusText(status) {
    const statusMap = {
        'BORROWED': '借阅中',
        'RETURNED': '已归还',
        'OVERDUE': '逾期未还',
        'RENEWED': '已续借'
    };
    return statusMap[status] || status;
}

// 获取状态样式类
function getStatusClass(status) {
    const classMap = {
        'BORROWED': 'btn-primary',
        'RETURNED': 'btn-success',
        'OVERDUE': 'btn-danger',
        'RENEWED': 'btn-warning'
    };
    return classMap[status] || 'btn-secondary';
}

// 搜索借阅记录
async function searchBorrows(page = 0) {
    const userId = document.getElementById('borrowSearch').value.trim();
    if (!userId) {
        loadBorrows();
        return;
    }
    
    try {
        const response = await fetch(`${API_BASE}/borrow-records/user/${userId}`);
        if (response.ok) {
            const records = await response.json();
            displayBorrows(records);
            document.getElementById('borrowsPagination').innerHTML = '';
        }
    } catch (error) {
        showMessage('搜索失败: ' + error.message, 'danger');
    }
}

// 归还图书
async function returnBook(id) {
    if (!confirm('确定要归还这本图书吗？')) return;
    
    try {
        const response = await fetch(`${API_BASE}/borrow-records/return/${id}`, {
            method: 'POST'
        });
        
        if (response.ok) {
            showMessage('图书归还成功！', 'success');
            loadBorrows();
            loadDashboard();
        } else {
            const error = await response.json();
            showMessage(error.message || '归还失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 续借图书
async function renewBook(id) {
    if (!confirm('确定要续借这本图书吗？')) return;
    
    try {
        const response = await fetch(`${API_BASE}/borrow-records/renew/${id}`, {
            method: 'POST'
        });
        
        if (response.ok) {
            showMessage('图书续借成功！', 'success');
            loadBorrows();
        } else {
            const error = await response.json();
            showMessage(error.message || '续借失败', 'danger');
        }
    } catch (error) {
        showMessage('网络错误: ' + error.message, 'danger');
    }
}

// 显示模态框
function showAddBookModal() {
    document.getElementById('addBookModal').style.display = 'block';
}

function showAddUserModal() {
    document.getElementById('addUserModal').style.display = 'block';
}

function showBorrowModal(bookId) {
    document.getElementById('borrowBookId').value = bookId;
    document.getElementById('borrowBookModal').style.display = 'block';
}

// 关闭模态框
function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// 显示提示信息
function showAlert(elementId, message, type) {
    const alert = document.getElementById(elementId);
    alert.className = `alert alert-${type}`;
    alert.textContent = message;
    alert.classList.remove('hidden');
}

function clearAlert(elementId) {
    const alert = document.getElementById(elementId);
    alert.classList.add('hidden');
}

function showMessage(message, type) {
    // 创建临时提示
    const div = document.createElement('div');
    div.className = `alert alert-${type}`;
    div.textContent = message;
    div.style.position = 'fixed';
    div.style.top = '20px';
    div.style.right = '20px';
    div.style.zIndex = '9999';
    
    document.body.appendChild(div);
    
    setTimeout(() => {
        document.body.removeChild(div);
    }, 3000);
}

// 渲染分页
function renderPagination(containerId, totalPages, currentPage, loadFunction) {
    const container = document.getElementById(containerId);
    container.innerHTML = '';
    
    if (totalPages <= 1) return;
    
    // 上一页
    if (currentPage > 0) {
        const prevBtn = document.createElement('button');
        prevBtn.textContent = '上一页';
        prevBtn.onclick = () => loadFunction(currentPage - 1);
        container.appendChild(prevBtn);
    }
    
    // 页码
    for (let i = 0; i < totalPages; i++) {
        if (i === 0 || i === totalPages - 1 || (i >= currentPage - 2 && i <= currentPage + 2)) {
            const pageBtn = document.createElement('button');
            pageBtn.textContent = i + 1;
            pageBtn.onclick = () => loadFunction(i);
            if (i === currentPage) {
                pageBtn.classList.add('active');
            }
            container.appendChild(pageBtn);
        } else if (i === currentPage - 3 || i === currentPage + 3) {
            const ellipsis = document.createElement('span');
            ellipsis.textContent = '...';
            ellipsis.style.padding = '5px';
            container.appendChild(ellipsis);
        }
    }
    
    // 下一页
    if (currentPage < totalPages - 1) {
        const nextBtn = document.createElement('button');
        nextBtn.textContent = '下一页';
        nextBtn.onclick = () => loadFunction(currentPage + 1);
        container.appendChild(nextBtn);
    }
}

// 点击模态框外部关闭
window.onclick = function(event) {
    if (event.target.classList.contains('modal')) {
        event.target.style.display = 'none';
    }
}