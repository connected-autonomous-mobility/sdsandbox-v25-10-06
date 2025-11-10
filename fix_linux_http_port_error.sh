#!/bin/bash
# Fix for Unity HTTP REST Server Port Error on Linux
# This script helps diagnose and fix the "Error opening a HTTP REST server port between 38000 and 38100" error

set -e

echo "======================================"
echo "Unity HTTP Port Error Fix Script"
echo "======================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    print_error "This script is intended for Linux systems only."
    exit 1
fi

print_info "Detected OS: $OSTYPE"
print_info "Checking for common issues..."
echo ""

# Check 1: Port conflicts
echo "1. Checking for port conflicts (38000-38100)..."
if command -v netstat &> /dev/null; then
    PORTS_IN_USE=$(sudo netstat -tulpn 2>/dev/null | grep -E "380[0-9]{2}" || true)
    if [ -n "$PORTS_IN_USE" ]; then
        print_error "Found ports in use:"
        echo "$PORTS_IN_USE"
        echo ""
        read -p "Do you want to see process details? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo netstat -tulpn | grep -E "380[0-9]{2}"
        fi
    else
        print_success "No port conflicts detected"
    fi
else
    print_info "netstat not available, skipping port check"
fi
echo ""

# Check 2: SSL libraries
echo "2. Checking for libssl1.0.0..."
if dpkg -l | grep -q libssl1.0.0; then
    print_success "libssl1.0.0 is already installed"
else
    print_error "libssl1.0.0 is NOT installed (this is likely the cause)"
    echo ""
    read -p "Do you want to install libssl1.0.0? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "Downloading libssl1.0.0..."
        wget http://security.ubuntu.com/ubuntu/pool/main/o/openssl1.0/libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
        
        print_info "Installing libssl1.0.0..."
        sudo dpkg -i libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
        
        print_info "Fixing dependencies..."
        sudo apt-get -f install -y
        
        print_success "libssl1.0.0 installed successfully"
        
        # Clean up
        rm -f libssl1.0.0_1.0.2n-1ubuntu5_amd64.deb
    else
        print_info "Skipping libssl installation"
    fi
fi
echo ""

# Check 3: Firewall
echo "3. Checking firewall configuration..."
if command -v ufw &> /dev/null; then
    UFW_STATUS=$(sudo ufw status 2>/dev/null || echo "inactive")
    if echo "$UFW_STATUS" | grep -q "Status: active"; then
        print_info "UFW firewall is active"
        if echo "$UFW_STATUS" | grep -q "38000:38100"; then
            print_success "Ports 38000-38100 are already open"
        else
            print_error "Ports 38000-38100 may not be open"
            echo ""
            read -p "Do you want to open ports 38000-38100? (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                sudo ufw allow 38000:38100/tcp
                print_success "Ports 38000-38100 opened"
            else
                print_info "Skipping firewall configuration"
            fi
        fi
    else
        print_success "UFW firewall is not active"
    fi
else
    print_info "UFW not available, skipping firewall check"
fi
echo ""

# Check 4: System information
echo "4. System Information:"
if command -v lsb_release &> /dev/null; then
    print_info "Distribution: $(lsb_release -d | cut -f2)"
    print_info "Version: $(lsb_release -r | cut -f2)"
else
    print_info "lsb_release not available"
fi
print_info "Kernel: $(uname -r)"
echo ""

# Summary
echo "======================================"
echo "Summary"
echo "======================================"
echo ""
print_info "If you're still experiencing issues, please check:"
echo "  - Unity Console for detailed error messages"
echo "  - docs/troubleshooting/linux_http_port_error.md for more solutions"
echo "  - System logs: journalctl -xe | grep -i 'unity\|port\|ssl'"
echo ""
print_success "Script completed. Please restart Unity and try again."
