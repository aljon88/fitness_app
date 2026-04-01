# Clean Restart Script for Flutter App
# This script stops Flutter, clears browser cache, and restarts clean

Write-Host "🧹 Starting Clean Restart Process..." -ForegroundColor Cyan
Write-Host ""

# Step 1: Stop any running Flutter processes
Write-Host "1️⃣ Stopping Flutter processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*dart*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   ✅ Flutter processes stopped" -ForegroundColor Green
Start-Sleep -Seconds 1

# Step 2: Close Chrome processes (to clear cache)
Write-Host ""
Write-Host "2️⃣ Closing Chrome browsers..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -eq "chrome"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   ✅ Chrome closed" -ForegroundColor Green
Start-Sleep -Seconds 2

# Step 3: Clear Chrome cache data
Write-Host ""
Write-Host "3️⃣ Clearing Chrome cache..." -ForegroundColor Yellow
$chromeCachePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Service Worker\CacheStorage",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Local Storage"
)

foreach ($path in $chromeCachePaths) {
    if (Test-Path $path) {
        try {
            Remove-Item -Path "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "   ✅ Cleared: $path" -ForegroundColor Green
        } catch {
            Write-Host "   ⚠️ Could not clear: $path" -ForegroundColor Yellow
        }
    }
}

# Step 4: Clean Flutter build cache
Write-Host ""
Write-Host "4️⃣ Cleaning Flutter build cache..." -ForegroundColor Yellow
if (Test-Path "build") {
    Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "   ✅ Build folder cleaned" -ForegroundColor Green
}

# Step 5: Wait a moment
Write-Host ""
Write-Host "5️⃣ Waiting for cleanup to complete..." -ForegroundColor Yellow
Start-Sleep -Seconds 2
Write-Host "   ✅ Cleanup complete" -ForegroundColor Green

# Step 6: Start Flutter with clean state
Write-Host ""
Write-Host "6️⃣ Starting Flutter app..." -ForegroundColor Yellow
Write-Host ""
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   🚀 Launching app with clean browser session" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Run Flutter
C:\flutter\bin\flutter.bat run -d chrome

Write-Host ""
Write-Host "✨ Clean restart complete!" -ForegroundColor Green
