#!/bin/bash
set -e

echo "=== Step 1: Downloading and installing UTM ==="
UTM_URL=$(curl -s https://api.github.com/repos/utmapp/UTM/releases/latest | grep "browser_download_url" | grep "UTM.dmg" | cut -d '"' -f 4)
curl -L -o /tmp/UTM.dmg "$UTM_URL"
hdiutil attach /tmp/UTM.dmg -mountpoint /Volumes/UTM

# Use 'ditto' to properly copy app bundles with symlinks intact
sudo ditto /Volumes/UTM/UTM.app /Applications/UTM.app

hdiutil detach /Volumes/UTM
rm /tmp/UTM.dmg
echo "UTM installed successfully in /Applications."

echo "=== Step 2: Creating Debian ARM64 VM configuration for UTM ==="
VM_NAME="Whonix-Builder"
echo 'export PATH="$PATH:/Applications/UTM.app/Contents/MacOS"' >> ~/.zshrc
source ~/.zshrc

echo "=== Step 3: Setting up build dependencies inside Debian ==="
cat << 'EOF' > /tmp/build_whonix.sh
#!/bin/bash
sudo apt-get update && sudo apt-get install -y git curl sudo
git clone https://github.com/Whonix/derivative-maker.git ~/derivative-maker
cd ~/derivative-maker
./derivative-maker --target qemu --arch arm64
EOF

chmod +x /tmp/build_whonix.sh
echo "Setup script prepared. Start your '$VM_NAME' VM in UTM, copy /tmp/build_whonix.sh inside it, and run it to compile the images."
