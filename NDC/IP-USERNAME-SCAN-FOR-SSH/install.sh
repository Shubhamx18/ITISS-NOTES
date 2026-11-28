#!/bin/bash
# ============================================================
# File 1: install.sh
# Purpose: Installs all required dependencies for the scanner
# ============================================================

echo "========================================="
echo " 1. INSTALLING REQUIRED TOOLS"
echo "========================================="

# Detect package manager
if command -v dnf &>/dev/null; then
    PKG="dnf"
elif command -v yum &>/dev/null; then
    PKG="yum"
else
    echo "[!] Neither dnf nor yum found. This script requires CentOS/RHEL/Fedora."
    exit 1
fi

# Install sshpass if missing
if ! command -v sshpass &>/dev/null; then
    echo "[*] sshpass not found. Installing..."
    sudo $PKG install -y sshpass || {
        echo "[*] Base repo failed. Trying EPEL..."
        sudo $PKG install -y epel-release
        sudo $PKG install -y sshpass
    }
else
    echo "[+] sshpass is already installed."
fi

# Verify ssh client
if ! command -v ssh &>/dev/null; then
    echo "[*] Installing openssh-clients..."
    sudo $PKG install -y openssh-clients
else
    echo "[+] ssh client is already installed."
fi

# Final check
if command -v sshpass &>/dev/null && command -v ssh &>/dev/null; then
    echo ""
    echo "========================================="
    echo "[+] INSTALLATION COMPLETE!"
    echo "========================================="
    echo "You can now run: ./scan.sh"
else
    echo ""
    echo "[!] INSTALLATION FAILED. Please check your internet/repos."
fi