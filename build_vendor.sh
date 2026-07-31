#!/bin/bash
# Shell script to auto build and zip vendor if vendor.zip does not exist.

VENDOR_ZIP="vendor.zip"

if [ -f "$VENDOR_ZIP" ]; then
    echo "[SKIP] vendor.zip already exists. Skipping composer install and re-zipping."
else
    echo "[BUILD] vendor.zip not found."
    if command -v composer >/dev/null 2>&1; then
        echo "Running composer install --no-dev --optimize-autoloader..."
        composer install --no-dev --optimize-autoloader
    else
        echo "[WARN] 'composer' CLI not found. Checking existing vendor directory..."
    fi

    if [ -d "vendor" ]; then
        echo "[ZIP] Compressing vendor directory into vendor.zip..."
        zip -r -q "$VENDOR_ZIP" vendor/
        echo "[SUCCESS] Created vendor.zip successfully!"
    else
        echo "[WARN] vendor directory missing."
    fi
fi
