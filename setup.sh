#!/bin/bash
set -e

echo "=== Step 1: Downloading and installing UTM ==="
UTM_URL=$(curl -s https://api.github.com/repos/utmapp/UTM/releases/latest | grep "browser_download_url" | grep "UTM.dmg" | cut -d '"' -f 4)
curl -L -o /tmp/UTM.dmg "$UTM_URL"
hdiutil attach /tmp/UTM.dmg -mountpoint /Volumes/UTM

if [ -d "/Applications/UTM.app" ]; then
    echo "Removing existing UTM.app..."
    sudo rm -rf /Applications/UTM.app
fi

sudo ditto /Volumes/UTM/UTM.app /Applications/UTM.app
hdiutil detach /Volumes/UTM
rm /tmp/UTM.dmg
echo "UTM installed successfully in /Applications."

# Ensure utmctl is accessible globally
if ! command -v utmctl &> /dev/null; then
    echo 'export PATH="$PATH:/Applications/UTM.app/Contents/MacOS"' >> ~/.zshrc
    export PATH="$PATH:/Applications/UTM.app/Contents/MacOS"
fi

echo "=== Step 2: Generating the internal build & Tor setup script ==="
cat << 'EOF' > /tmp/build_whonix.sh
#!/bin/bash
set -e

echo "Updating system packages and installing build dependencies..."
sudo apt-get update && sudo apt-get install -y git curl sudo apt-transport-https gnupg

echo "Cloning Whonix derivative-maker repository..."
if [ ! -d "$HOME/derivative-maker" ]; then
    git clone https://github.com/Whonix/derivative-maker.git ~/derivative-maker
fi

cd ~/derivative-maker

echo "Configuring and initiating the build for ARM64 QEMU/Tor target..."
./derivative-maker --target qemu --arch arm64
EOF

chmod +x /tmp/build_whonix.sh

echo "=== Step 3: Launching UTM for VM creation ==="
echo "Opening UTM. Please create a new Virtual Machine (Virtualize -> Linux -> Debian ARM64), assign 4GB RAM and 4 CPUs."
open -a UTM
