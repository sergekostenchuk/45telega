#!/bin/bash
# 45telega MCP Server - One-line Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/sergekostenchuk/45telega/main/install.sh | bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/sergekostenchuk/45telega"
INSTALL_DIR="$HOME/.local/share/45telega"
BIN_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/45telega"

# Functions
print_header() {
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}    45telega MCP Server Installation${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

check_requirements() {
    print_info "Checking system requirements..."
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
    REQUIRED_VERSION="3.9"
    
    if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
        print_error "Python $REQUIRED_VERSION or higher is required (found $PYTHON_VERSION)"
        exit 1
    fi
    print_success "Python $PYTHON_VERSION found"
    
    # Check pip
    if ! python3 -m pip --version &> /dev/null; then
        print_error "pip is not installed"
        exit 1
    fi
    print_success "pip is installed"
    
    # Check git (optional for updates)
    if command -v git &> /dev/null; then
        print_success "git is installed (updates enabled)"
        HAS_GIT=true
    else
        print_info "git not found (manual updates required)"
        HAS_GIT=false
    fi
    
    # Check Docker (optional)
    if command -v docker &> /dev/null; then
        print_success "Docker is installed (container mode available)"
        HAS_DOCKER=true
    else
        print_info "Docker not found (native mode only)"
        HAS_DOCKER=false
    fi
}

create_directories() {
    print_info "Creating directories..."
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$BIN_DIR"
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$HOME/.local/state/mcp-telegram"
    print_success "Directories created"
}

download_and_install() {
    print_info "Downloading 45telega..."
    
    if [ "$HAS_GIT" = true ]; then
        # Clone with git
        if [ -d "$INSTALL_DIR/.git" ]; then
            print_info "Updating existing installation..."
            cd "$INSTALL_DIR"
            git pull origin main
        else
            git clone "$REPO_URL" "$INSTALL_DIR"
        fi
    else
        # Download release archive
        LATEST_RELEASE=$(curl -s https://api.github.com/repos/sergekostenchuk/45telega/releases/latest | grep "tarball_url" | cut -d '"' -f 4)
        curl -L "$LATEST_RELEASE" | tar xz -C "$INSTALL_DIR" --strip-components=1
    fi
    print_success "Downloaded successfully"
    
    # Install Python package
    print_info "Installing Python package..."
    cd "$INSTALL_DIR"
    python3 -m pip install --user -e . --upgrade
    print_success "Python package installed"
    
    # Create executable link
    print_info "Creating executable..."
    cat > "$BIN_DIR/45telega" << 'EOF'
#!/usr/bin/env python3
import sys
import os
sys.path.insert(0, os.path.expanduser("~/.local/share/45telega"))
from telega45.cli import main
if __name__ == "__main__":
    main()
EOF
    chmod +x "$BIN_DIR/45telega"
    print_success "Executable created"
}

setup_configuration() {
    print_info "Setting up configuration..."
    
    if [ ! -f "$CONFIG_DIR/.env" ]; then
        cp "$INSTALL_DIR/.env.example" "$CONFIG_DIR/.env"
        print_info "Configuration template created at $CONFIG_DIR/.env"
        print_info "Please edit this file with your Telegram credentials"
    else
        print_info "Configuration already exists, skipping..."
    fi
    
    # Add to PATH if needed
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        print_info "Adding $BIN_DIR to PATH..."
        
        # Detect shell
        if [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        elif [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
        else
            SHELL_RC="$HOME/.profile"
        fi
        
        echo "" >> "$SHELL_RC"
        echo "# 45telega MCP Server" >> "$SHELL_RC"
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$SHELL_RC"
        
        print_success "PATH updated in $SHELL_RC"
        print_info "Run 'source $SHELL_RC' or restart your terminal"
    fi
}

setup_docker() {
    if [ "$HAS_DOCKER" = true ]; then
        print_info "Setting up Docker..."
        cd "$INSTALL_DIR"
        
        # Build Docker image
        docker build -t 45telega:latest .
        print_success "Docker image built"
        
        # Create docker-compose override
        if [ ! -f "$CONFIG_DIR/docker-compose.override.yml" ]; then
            cat > "$CONFIG_DIR/docker-compose.override.yml" << EOF
version: '3.8'
services:
  45telega:
    env_file:
      - $CONFIG_DIR/.env
EOF
            print_success "Docker compose override created"
        fi
    fi
}

verify_installation() {
    print_info "Verifying installation..."
    
    if command -v 45telega &> /dev/null; then
        print_success "45telega command is available"
        
        # Test import
        if python3 -c "import telega45" 2>/dev/null; then
            print_success "Python module imports successfully"
        else
            print_error "Failed to import Python module"
            exit 1
        fi
    else
        print_error "45telega command not found"
        print_info "You may need to reload your shell or add $BIN_DIR to PATH"
    fi
}

print_next_steps() {
    echo ""
    print_header
    echo -e "${GREEN}Installation completed successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "1. Edit configuration: ${BLUE}$CONFIG_DIR/.env${NC}"
    echo "2. Add your Telegram API credentials"
    echo "3. Run first authentication: ${BLUE}45telega sign-in${NC}"
    echo "4. Start the MCP server: ${BLUE}45telega run${NC}"
    echo ""
    if [ "$HAS_DOCKER" = true ]; then
        echo "Docker mode available:"
        echo "  ${BLUE}cd $INSTALL_DIR && docker-compose up -d${NC}"
    fi
    echo ""
    echo "Documentation: ${BLUE}$REPO_URL${NC}"
    echo ""
}

# Main installation flow
main() {
    print_header
    check_requirements
    create_directories
    download_and_install
    setup_configuration
    setup_docker
    verify_installation
    print_next_steps
}

# Run installation
main "$@"
