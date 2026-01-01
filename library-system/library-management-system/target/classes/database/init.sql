-- 创建数据库
CREATE DATABASE IF NOT EXISTS library_db 
DEFAULT CHARACTER SET utf8mb4 
DEFAULT COLLATE utf8mb4_unicode_ci;

-- 使用数据库
USE library_db;

-- 创建图书表
CREATE TABLE IF NOT EXISTS books (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    publisher VARCHAR(100) NOT NULL,
    publish_year INT,
    category VARCHAR(50) NOT NULL,
    total_copies INT NOT NULL DEFAULT 1,
    available_copies INT NOT NULL DEFAULT 1,
    price DECIMAL(10, 2),
    location VARCHAR(50),
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_title (title),
    INDEX idx_author (author),
    INDEX idx_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建用户表
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL,
    real_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    user_type ENUM('ADMIN', 'READER') NOT NULL DEFAULT 'READER',
    status INT NOT NULL DEFAULT 1 COMMENT '1-正常, 0-禁用',
    borrow_count INT NOT NULL DEFAULT 0,
    max_borrow_limit INT NOT NULL DEFAULT 5,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_user_type (user_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建借阅记录表
CREATE TABLE IF NOT EXISTS borrow_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    book_id BIGINT NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status ENUM('BORROWED', 'RETURNED', 'OVERDUE', 'RENEWED') NOT NULL DEFAULT 'BORROWED',
    fine DECIMAL(10, 2) DEFAULT 0.00,
    renew_count INT NOT NULL DEFAULT 0,
    create_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    update_time DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_book_id (book_id),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 插入默认管理员用户（密码: admin123）
INSERT IGNORE INTO users (username, password, real_name, email, user_type, status, max_borrow_limit) 
VALUES ('admin', 'admin123', '系统管理员', 'admin@library.com', 'ADMIN', 1, 10);

-- 插入测试读者用户（密码: user123）
INSERT IGNORE INTO users (username, password, real_name, email, user_type, status) 
VALUES ('testuser', 'user123', '测试用户', 'test@library.com', 'READER', 1);

-- 插入示例图书数据
INSERT IGNORE INTO books (isbn, title, author, publisher, publish_year, category, total_copies, available_copies, price, location) VALUES
('9787302164', 'Java程序设计语言', '杨佩璐', '清华大学出版社', 2017, '计算机科学', 5, 4, 49.80, 'A区-1架'),
('9787115428', 'Spring Boot实战', 'Craig Walls', '人民邮电出版社', 2016, '计算机科学', 3, 2, 59.00, 'A区-2架'),
('9787115546', '深入理解Java虚拟机', '周志明', '机械工业出版社', 2019, '计算机科学', 4, 3, 79.00, 'A区-3架'),
('9787508662', '人类简史', '尤瓦尔·赫拉利', '中信出版社', 2017, '历史', 6, 5, 68.00, 'B区-1架'),
('9787020024', '红楼梦', '曹雪芹', '人民文学出版社', 2008, '文学', 10, 8, 59.70, 'C区-1架'),
('9787532737', '百年孤独', '加西亚·马尔克斯', '上海译文出版社', 2011, '文学', 5, 3, 39.50, 'C区-2架'),
('9787115279', '数学之美', '吴军', '人民邮电出版社', 2014, '数学', 4, 4, 45.00, 'D区-1架'),
('9787111582', '算法导论', 'Thomas H. Cormen', '机械工业出版社', 2013, '计算机科学', 3, 2, 128.00, 'A区-4架');

-- 创建视图：图书借阅统计
CREATE OR REPLACE VIEW book_borrow_stats AS
SELECT 
    b.id,
    b.isbn,
    b.title,
    b.author,
    b.category,
    b.total_copies,
    b.available_copies,
    (b.total_copies - b.available_copies) as borrowed_count,
    COUNT(br.id) as total_borrow_times
FROM books b
LEFT JOIN borrow_records br ON b.id = br.book_id
GROUP BY b.id;

-- 创建视图：用户借阅统计
CREATE OR REPLACE VIEW user_borrow_stats AS
SELECT 
    u.id,
    u.username,
    u.real_name,
    u.user_type,
    u.borrow_count,
    u.max_borrow_limit,
    COUNT(br.id) as total_borrows,
    COUNT(CASE WHEN br.status = 'BORROWED' THEN 1 END) as current_borrows,
    COUNT(CASE WHEN br.status = 'OVERDUE' THEN 1 END) as overdue_borrows
FROM users u
LEFT JOIN borrow_records br ON u.id = br.user_id
GROUP BY u.id;

-- 设置root用户密码（如果未设置）
-- 注意：请根据实际情况修改密码
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';

-- 刷新权限
FLUSH PRIVILEGES;