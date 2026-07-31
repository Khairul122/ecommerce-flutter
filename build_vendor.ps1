# PowerShell script to auto build and zip vendor if vendor.zip does not exist.

$vendorZip = "vendor.zip"

if (Test-Path $vendorZip) {
    Write-Host "[SKIP] vendor.zip already exists. Skipping composer install and re-zipping." -ForegroundColor Green
} else {
    Write-Host "[BUILD] vendor.zip not found." -ForegroundColor Yellow
    
    # Try running composer if command exists
    if (Get-Command "composer" -ErrorAction SilentlyContinue) {
        Write-Host "Running composer install --no-dev --optimize-autoloader..." -ForegroundColor Yellow
        composer install --no-dev --optimize-autoloader
    } else {
        Write-Host "[WARN] 'composer' CLI not found in PATH. Checking for existing vendor directory..." -ForegroundColor Yellow
    }

    if (Test-Path "vendor") {
        Write-Host "[ZIP] Compressing existing vendor directory into vendor.zip..." -ForegroundColor Yellow
        Compress-Archive -Path "vendor\*" -DestinationPath $vendorZip -Force
        Write-Host "[SUCCESS] Created vendor.zip successfully!" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] vendor directory not found!" -ForegroundColor Red
    }
}
