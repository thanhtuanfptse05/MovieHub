# =========================================================================
# MovieHub - PowerShell Database Installer
# =========================================================================
param(
    [string]$Server = "localhost",
    [string]$Username = "sa",
    [string]$Password = "123",
    [string]$Database = "MovieHub"
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host " MovieHub - Cài Đặt Cơ Sở Dữ Liệu SQL Server" -ForegroundColor Cyan
Write-Host " Server: $Server | User: $Username | Database: $Database" -ForegroundColor Gray
Write-Host "=========================================================================" -ForegroundColor Cyan

$Files = @(
    "01_schema.sql",
    "02_reset_data.sql",
    "03_seed_users.sql",
    "04_seed_categories.sql",
    "05_seed_movies.sql",
    "06_seed_favorites.sql",
    "07_seed_reviews.sql",
    "08_seed_qa.sql"
)

$step = 1
foreach ($f in $Files) {
    $filePath = Join-Path $ScriptDir $f
    Write-Host "[$step/$($Files.Count)] Đang thực thi $f..." -ForegroundColor Yellow
    
    $proc = Start-Process -FilePath "sqlcmd" `
        -ArgumentList "-I", "-b", "-f", "65001", "-S", $Server, "-U", $Username, "-P", $Password, "-d", $Database, "-C", "-i", "`"$filePath`"" `
        -NoNewWindow -Wait -PassThru

    if ($proc.ExitCode -ne 0) {
        Write-Host "[LỖI] Thực thi file $f thất bại với mã lỗi $($proc.ExitCode)!" -ForegroundColor Red
        exit $proc.ExitCode
    }
    $step++
}

Write-Host "=========================================================================" -ForegroundColor Green
Write-Host " Khởi tạo và nạp dữ liệu MovieHub thành công 100%!" -ForegroundColor Green
Write-Host "=========================================================================" -ForegroundColor Green
