@echo off
chcp 65001 >nul
echo ==========================================
echo     图书馆管理系统 - 一键部署脚本
echo ==========================================
echo.

:: 检查是否以管理员身份运行
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [√] 已以管理员身份运行
) else (
    echo [×] 需要以管理员身份运行
    echo 请右键点击此脚本，选择"以管理员身份运行"
    pause
    exit /b
)

:: 设置变量
set PROJECT_NAME=library-management-system
set PROJECT_DIR=%CD%\%PROJECT_NAME%
set MYSQL_PORT=3306
set MYSQL_USER=root
set MYSQL_PASSWORD=123456


:: 检查Java是否已安装
java -version >nul 2>&1
if %errorLevel% == 0 (
    echo [√] Java已安装
) else (
    echo [×] 未检测到Java
    echo 请先安装Java 8或更高版本
    pause
    exit /b
)

echo.
echo ==========================================
echo        第一步：检查MySQL服务
echo ==========================================
echo.

:: 检查MySQL服务
sc query MySQL >nul 2>&1
if %errorLevel% == 0 (
    echo [√] 检测到MySQL服务
    goto :check_mysql_connection
) else (
    sc query MySQL80 >nul 2>&1
    if %errorLevel% == 0 (
        echo [√] 检测到MySQL80服务
        set MYSQL_SERVICE=MySQL80
        goto :check_mysql_connection
    ) else (
        sc query mysqld >nul 2>&1
        if %errorLevel% == 0 (
            echo [√] 检测到mysqld服务
            set MYSQL_SERVICE=mysqld
            goto :check_mysql_connection
        ) else (
            echo [×] 未检测到MySQL服务
            echo 请先安装MySQL并启动服务
            pause
            exit /b
        )
    )
)

:check_mysql_connection
echo.
echo ==========================================
echo        第二步：检查MySQL连接
echo ==========================================
echo.

:: 检查MySQL连接
mysql -hlocalhost -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% -e "SELECT 'MySQL连接成功';" >nul 2>&1
if %errorLevel% == 0 (
    echo [√] MySQL连接成功
    goto :setup_database
) else (
    echo [×] MySQL连接失败
    echo 请检查MySQL用户名和密码是否正确
    echo 默认用户名: root
    echo 默认密码: 123456
    echo.
    echo 如果需要修改密码，请：
    echo 1. 编辑 deploy.bat 文件修改 MYSQL_PASSWORD 变量
    echo 2. 或修改 application.properties 文件中的数据库密码
    pause
    exit /b
)

:setup_database
echo.
echo ==========================================
echo        第三步：创建数据库
echo ==========================================
echo.

:: 创建数据库和表
echo [>] 正在创建数据库和表...
mysql -hlocalhost -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% < "%PROJECT_DIR%\src\main\resources\database\init.sql"
if %errorLevel% == 0 (
    echo [√] 数据库创建成功
) else (
    echo [×] 数据库创建失败
    pause
    exit /b
)

echo.
echo ==========================================
echo        第四步：构建项目
echo ==========================================
echo.

:: 检查Maven
call mvn --version >nul 2>&1
if %errorLevel% == 0 (
    echo [√] Maven已安装
) else (
    echo [×] 未检测到Maven
    echo 正在尝试使用项目内置的Maven Wrapper...
)

echo [>] 正在构建项目...
cd "%PROJECT_DIR%"
if exist mvnw.cmd (
    call mvnw.cmd clean package -DskipTests
) else (
    call mvn clean package -DskipTests
)

if %errorLevel% == 0 (
    echo [√] 项目构建成功
) else (
    echo [×] 项目构建失败
    pause
    exit /b
)

cd ..

echo.
echo ==========================================
echo        第五步：创建启动脚本
echo ==========================================
echo.

:: 创建启动脚本
echo [>] 正在创建启动脚本...
(
echo @echo off
echo chcp 65001 ^>nul
echo title 图书馆管理系统
echo.
echo ==========================================
echo     图书馆管理系统正在启动...
echo ==========================================
echo.
echo 系统启动后，请访问: http://localhost:8080
echo.
echo 默认管理员账号:
echo   用户名: admin
echo   密码: admin123
echo.
echo 默认测试账号:
echo   用户名: testuser
echo   密码: user123
echo.
echo ==========================================
echo.
java -jar "%PROJECT_DIR%\target\library-management-system-1.0.0.jar" --server.port=8080
) > start-library-system.bat

echo [√] 启动脚本创建成功

echo.
echo ==========================================
echo        第六步：创建数据库重置脚本
echo ==========================================
echo.

:: 创建数据库重置脚本
(
echo @echo off
echo chcp 65001 ^>nul
echo.
echo ==========================================
echo     重置图书馆管理系统数据库
echo ==========================================
echo.
echo [^>] 正在重置数据库...
mysql -hlocalhost -P%MYSQL_PORT% -u%MYSQL_USER% -p%MYSQL_PASSWORD% ^< "%PROJECT_DIR%\src\main\resources\database\init.sql"
if %%errorLevel%% == 0 (
    echo [^√] 数据库重置成功
) else (
    echo [^×] 数据库重置失败
)
echo.
pause
) > reset-database.bat

echo [√] 数据库重置脚本创建成功

echo.
echo ==========================================
echo        部署完成！
echo ==========================================
echo.
echo [√] 所有步骤已完成！
echo.
echo 使用方法：
echo 1. 双击运行 start-library-system.bat 启动系统
echo 2. 打开浏览器访问: http://localhost:8080
echo 3. 使用以下账号登录：
echo    管理员: admin / admin123
echo    测试用户: testuser / user123
echo.
echo 如果需要重新部署：
echo 1. 运行 reset-database.bat 重置数据库
echo 2. 重新运行 deploy.bat
echo.
echo 项目源码位置: %PROJECT_DIR%
echo 数据库配置文件: %PROJECT_DIR%\src\main\resources\application.properties
echo.
echo 按任意键退出...
pause >nul