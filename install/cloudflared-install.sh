#!/bin/bash

# Detect OS and architecture
OS="$(uname -s)"
ARCH="$(uname -m)"

# Set binary URL based on architecture
if [[ "$ARCH" == "x86_64" ]]; then
    BINARY_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64"
elif [[ "$ARCH" == "armv7l" ]]; then
    BINARY_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm"
elif [[ "$ARCH" == "aarch64" ]] || [[ "$ARCH" == "arm64" ]]; then
    BINARY_URL="https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# MacOS check
if [[ "$OS" == "Darwin" ]]; then
    echo "Detected macOS. Installing via Homebrew..."
    if ! command -v brew &>/dev/null; then
        echo "Homebrew not found! Install Homebrew first: https://brew.sh/"
        exit 1
    fi
    brew install cloudflare/cloudflare/cloudflared
    exit 0
fi

# Download the correct binary for Linux systems
echo "Downloading cloudflared binary for $ARCH..."
wget -q "$BINARY_URL" -O cloudflared

if [[ $? -ne 0 ]]; then
    echo "Download failed! Please check your internet connection or URL."
    exit 1
fi

# Move binary to /usr/local/bin, make executable
echo "Installing cloudflared..."
sudo mv cloudflared /usr/local/bin/cloudflared
sudo chmod +x /usr/local/bin/cloudflared

# Verify installation
echo "Verifying cloudflared installation..."
if cloudflared --version &>/dev/null; then
    echo "cloudflared installed successfully!"
else
    echo "Installation failed."
    exit 1
fi
