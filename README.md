图书馆管理系统 (Library Management System)
一个基于Spring Boot和MySQL的现代化图书馆管理系统，提供图书管理、用户管理、借阅管理等核心功能。

功能特色
📚 图书管理
图书信息录入、编辑、删除
支持ISBN、书名、作者、分类等多维度搜索
图书库存管理（总数量、可借数量）
图书分类统计
👥 用户管理
用户注册与登录
管理员与读者权限分离
用户借阅额度管理
用户状态管理（正常/禁用）
📖 借阅管理
图书借阅与归还
借阅期限管理（默认30天）
续借功能（最多续借2次）
逾期罚款计算
借阅记录查询
📊 系统统计
总图书数量统计
可借图书数量
注册用户数量
借阅中图书数量
技术架构
后端技术栈
Spring Boot 2.7.18 - Web框架
Spring Data JPA - 数据访问层
MySQL 8.0 - 数据库
Maven - 项目构建工具
前端技术栈
HTML5 + CSS3 + JavaScript - 前端页面
Bootstrap风格UI - 用户界面
RESTful API - 前后端通信
部署环境要求
必需软件
Java 8+ - Java运行环境
MySQL 5.7+ - 数据库
Maven 3.6+ - 项目构建工具（可选，项目包含Maven Wrapper）
推荐环境
Windows 10/11 或 Linux/Unix
IntelliJ IDEA - Java开发IDE
MySQL Workbench - 数据库管理工具
一键部署（Windows）
步骤一：准备工作
确保已安装以下软件：

Java 8 或更高版本
MySQL 5.7 或更高版本
MySQL服务已启动
解压项目文件到任意目录

步骤二：修改数据库配置（如需要）
如果MySQL的root用户密码不是123456，请修改配置文件：

# 文件路径: library-management-system\src\main\resources\application.properties

spring.datasource.url=jdbc:mysql://localhost:3306/library_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false
spring.datasource.username=root
spring.datasource.password=你的MySQL密码  # ← 修改这里
步骤三：运行部署脚本
右键点击 deploy.bat 文件
选择 "以管理员身份运行"
等待脚本自动完成部署
步骤四：启动系统
部署完成后，会生成 start-library-system.bat
双击运行该文件启动系统
打开浏览器访问: http://localhost:8080
手动部署步骤
1. 创建数据库
-- 登录MySQL
mysql -uroot -p

-- 创建数据库
CREATE DATABASE library_db DEFAULT CHARACTER SET utf8mb4;

-- 执行初始化脚本
source library-management-system/src/main/resources/database/init.sql
2. 构建项目
cd library-management-system

# 使用Maven Wrapper（Windows）
mvnw.cmd clean package -DskipTests

# 使用Maven（已安装Maven）
mvn clean package -DskipTests
3. 运行项目
# 运行JAR文件
java -jar target/library-management-system-1.0.0.jar
4. 访问系统
打开浏览器访问: http://localhost:8080

默认账号
管理员账号
用户名: admin
密码: admin123
权限: 系统管理、图书管理、用户管理、借阅管理
测试用户账号
用户名: testuser
密码: user123
权限: 图书查询、个人借阅
系统功能详解
图书管理功能
添加图书
点击"图书管理" → "添加图书"
填写图书信息：
ISBN（必填）
书名（必填）
作者（必填）
出版社（必填）
出版年份
分类（必填）
总数量（必填）
价格
存放位置
搜索图书
支持按书名、作者、ISBN搜索
支持模糊匹配
分页显示结果
图书借阅
找到要借阅的图书
点击"借阅"按钮
输入用户ID
确认借阅
用户管理功能
添加用户
点击"用户管理" → "添加用户"
填写用户信息：
用户名（必填）
密码（必填）
真实姓名（必填）
邮箱（必填）
手机号
用户类型（管理员/读者）
用户权限
管理员: 拥有所有权限
读者: 只能查看图书和查询个人借阅记录
借阅管理功能
图书归还
在借阅管理页面找到对应记录
点击"归还"按钮
系统自动计算罚款（如有逾期）
图书续借
在借阅管理页面找到对应记录
点击"续借"按钮
借阅期限延长30天
逾期处理
系统自动检测逾期记录
逾期罚款：0.5元/天
逾期状态自动更新
数据库结构
主要数据表
books (图书表)
字段	类型	说明
id	BIGINT	主键
isbn	VARCHAR(20)	ISBN号
title	VARCHAR(200)	书名
author	VARCHAR(100)	作者
publisher	VARCHAR(100)	出版社
publish_year	INT	出版年份
category	VARCHAR(50)	分类
total_copies	INT	总数量
available_copies	INT	可借数量
price	DECIMAL(10,2)	价格
location	VARCHAR(50)	存放位置
users (用户表)
字段	类型	说明
id	BIGINT	主键
username	VARCHAR(50)	用户名
password	VARCHAR(100)	密码
real_name	VARCHAR(50)	真实姓名
email	VARCHAR(100)	邮箱
phone	VARCHAR(20)	手机号
user_type	ENUM	用户类型
status	INT	状态
borrow_count	INT	已借阅数量
max_borrow_limit	INT	最大借阅额度
borrow_records (借阅记录表)
字段	类型	说明
id	BIGINT	主键
user_id	BIGINT	用户ID
book_id	BIGINT	图书ID
borrow_date	DATE	借阅日期
due_date	DATE	应还日期
return_date	DATE	实际归还日期
status	ENUM	借阅状态
fine	DECIMAL(10,2)	罚款金额
renew_count	INT	续借次数
开发环境搭建（IDEA）
步骤一：导入项目
打开 IntelliJ IDEA
选择 "File" → "Open"
选择 library-management-system 文件夹
等待项目导入和依赖下载
步骤二：配置数据库
打开 src/main/resources/application.properties
修改数据库连接信息：
spring.datasource.url=jdbc:mysql://localhost:3306/library_db?useUnicode=true&characterEncoding=utf8&serverTimezone=Asia/Shanghai&useSSL=false
spring.datasource.username=root
spring.datasource.password=你的MySQL密码
步骤三：运行项目
找到 LibraryManagementSystemApplication.java
右键点击 → "Run 'LibraryManagementSystemApplication'"
等待项目启动完成
访问 http://localhost:8080
步骤四：调试项目
在代码中设置断点
使用 Debug 模式运行项目
通过浏览器访问触发断点
常见问题
Q1: 数据库连接失败
解决方案：

检查MySQL服务是否启动
检查数据库连接配置是否正确
确保数据库 library_db 已创建
Q2: 端口8080被占用
解决方案：

修改 application.properties 中的端口号：
server.port=8081
或关闭占用8080端口的程序
Q3: 项目启动失败
解决方案：

检查Java版本是否为8或更高
检查MySQL版本是否为5.7或更高
查看控制台错误信息进行排查
Q4: 无法访问系统
解决方案：

检查项目是否成功启动
检查防火墙是否阻止了8080端口
尝试使用 localhost:8080 访问
系统扩展
添加新功能
后端开发：

创建Entity类
创建Repository接口
创建Service类
创建Controller类
前端开发：

修改HTML页面
添加JavaScript逻辑
调用后端API
数据库扩展
如需添加新表或字段：

修改 src/main/resources/database/init.sql
在Entity类中添加对应字段
重新部署项目
技术支持
项目结构
library-management-system/
├── src/
│   ├── main/
│   │   ├── java/com/library/
│   │   │   ├── entity/          # 实体类
│   │   │   ├── repository/      # 数据访问层
│   │   │   ├── service/         # 业务逻辑层
│   │   │   ├── controller/      # 控制器层
│   │   │   └── LibraryManagementSystemApplication.java
│   │   └── resources/
│   │       ├── static/          # 静态资源
│   │       │   ├── index.html
│   │       │   └── script.js
│   │       ├── database/
│   │       │   └── init.sql
│   │       └── application.properties
│   └── test/
├── target/                      # 编译输出目录
├── pom.xml                      # Maven配置文件
└── README.md
API文档
认证相关
POST /api/auth/login - 用户登录
POST /api/auth/register - 用户注册
POST /api/auth/logout - 用户退出
图书管理
GET /api/books - 获取图书列表
GET /api/books/{id} - 获取图书详情
POST /api/books - 添加图书
PUT /api/books/{id} - 更新图书
DELETE /api/books/{id} - 删除图书
GET /api/books/search - 搜索图书
GET /api/books/available - 获取可借图书
用户管理
GET /api/users - 获取用户列表
GET /api/users/{id} - 获取用户详情
POST /api/users - 添加用户
PUT /api/users/{id} - 更新用户
DELETE /api/users/{id} - 删除用户
借阅管理
GET /api/borrow-records - 获取借阅记录
POST /api/borrow-records/borrow - 借阅图书
POST /api/borrow-records/return/{id} - 归还图书
POST /api/borrow-records/renew/{id} - 续借图书
开源协议
本项目仅供学习和参考使用。

联系方式
如有问题或建议，欢迎反馈。

祝您使用愉快！ 📚✨
