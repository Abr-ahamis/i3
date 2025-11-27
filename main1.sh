#!/bin/bash

# ================================
#  I3 FULL AUTO SETUP SCRIPT
# ================================

REPO_DIR="$HOME/i3-dotfiles"
REPO_URL="https://github.com/Abr-ahamis/new.git"   # <-- CHANGE THIS

echo "=== I3 Auto Setup Script Started ==="

# --------------------------------
# 1. Install all necessary packages
# --------------------------------
echo "[1] Installing required packages..."
sudo apt update
sudo apt install -y i3 i3blocks rofi picom feh git fonts-font-awesome xclip xdotool curl

# --------------------------------
# 2. Clone dotfiles repo
# --------------------------------
if [ -d "$REPO_DIR" ]; then
    echo "[2] Repo exists, pulling latest changes..."
    git -C "$REPO_DIR" pull
else
    echo "[2] Cloning dotfiles repo..."
    git clone "$REPO_URL" "$REPO_DIR"
fi

# --------------------------------
# 3. Ensure required folders exist
# --------------------------------
echo "[3] Checking folder structure..."
mkdir -p $HOME/.config/i3
mkdir -p $HOME/.config/i3blocks
mkdir -p $HOME/.config/rofi
mkdir -p $HOME/.config/picom
mkdir -p $HOME/.local/share/fonts
mkdir -p $HOME/.local/bin

# --------------------------------
# 4. Copy configs using rsync
# --------------------------------
echo "[4] Copying config files with rsync..."

rsync -av --progress "$REPO_DIR/i3/" "$HOME/.config/i3/"
rsync -av --progress "$REPO_DIR/i3blocks/" "$HOME/.config/i3blocks/"
rsync -av --progress "$REPO_DIR/rofi/" "$HOME/.config/rofi/"
rsync -av --progress "$REPO_DIR/picom/" "$HOME/.config/picom/"
rsync -av --progress "$REPO_DIR/fonts/" "$HOME/.local/share/fonts/"

# powermenu
if [ -f "$REPO_DIR/powermenu.sh" ]; then
    rsync -av "$REPO_DIR/powermenu.sh" "$HOME/.local/bin/powermenu.sh"
fi

# --------------------------------
# 5. Set permissions
# --------------------------------
echo "[5] Setting permissions..."
chmod +x $HOME/.local/bin/powermenu.sh
chmod -R 755 $HOME/.config/i3blocks
chmod -R 755 $HOME/.config/rofi

# --------------------------------
# 6. Update fonts
# --------------------------------
echo "[6] Updating fonts..."
fc-cache -fv

# --------------------------------
# 7. Install Rofi theme (if included)
# --------------------------------
if ls "$HOME/.config/rofi/"*.rasi 1> /dev/null 2>&1; then
    echo "[7] Rofi theme installed."
else
    echo "[7] No Rofi theme found in repo."
fi

# --------------------------------
# 8. Restart i3
# --------------------------------
echo "[8] Restarting i3..."
i3-msg restart

echo "=== Setup Complete! ==="
