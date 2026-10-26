@echo off
chcp 65001 >nul
echo =========================================================================
echo  MovieHub - Script Cài Đặt Cơ Sở Dữ Liệu SQL Server
echo =========================================================================
echo.

set SERVER_NAME=localhost
set DB_USER=sa
set DB_PASS=123
set DB_NAME=MovieHub

set /p SERVER_INPUT="Nhập SQL Server (mặc định %SERVER_NAME%): "
if not "%SERVER_INPUT%"=="" set SERVER_NAME=%SERVER_INPUT%

set /p USER_INPUT="Nhập tài khoản sa (mặc định %DB_USER%): "
if not "%USER_INPUT%"=="" set DB_USER=%USER_INPUT%

set /p PASS_INPUT="Nhập mật khẩu (mặc định %DB_PASS%): "
if not "%PASS_INPUT%"=="" set DB_PASS=%PASS_INPUT%

echo.
echo Đang kết nối tới %SERVER_NAME% với tài khoản %DB_USER%...
echo Thực thi tuần tự các file SQL...
echo.

cd /d "%~dp0"

echo [1/8] 01_schema.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 01_schema.sql
if errorlevel 1 goto ERROR

echo [2/8] 02_reset_data.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 02_reset_data.sql
if errorlevel 1 goto ERROR

echo [3/8] 03_seed_users.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 03_seed_users.sql
if errorlevel 1 goto ERROR

echo [4/8] 04_seed_categories.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 04_seed_categories.sql
if errorlevel 1 goto ERROR

echo [5/8] 05_seed_movies.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 05_seed_movies.sql
if errorlevel 1 goto ERROR

echo [6/8] 06_seed_favorites.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 06_seed_favorites.sql
if errorlevel 1 goto ERROR

echo [7/8] 07_seed_reviews.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 07_seed_reviews.sql
if errorlevel 1 goto ERROR

echo [8/8] 08_seed_qa.sql...
sqlcmd -I -b -f 65001 -S %SERVER_NAME% -U %DB_USER% -P %DB_PASS% -C -i 08_seed_qa.sql
if errorlevel 1 goto ERROR

echo.
echo =========================================================================
echo  HOÀN TẤT CÀI ĐẶT CƠ SỞ DỮ LIỆU MOVIEHUB THÀNH CÔNG!
echo =========================================================================
echo.
pause
exit /b 0

:ERROR
echo.
echo [LỖI] Có lỗi xảy ra trong quá trình thực thi file SQL.
echo Vui lòng kiểm tra lại thông tin kết nối và thông báo lỗi ở trên.
pause
exit /b 1
