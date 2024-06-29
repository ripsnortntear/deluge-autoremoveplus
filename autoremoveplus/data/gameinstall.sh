#!/bin/bash

# Set the user's home directory
USER_HOME=/home/gamer

# Set the log file
LOG_FILE=/var/log/steamdeck_setup.log

# Function to log messages
log() {
    echo "$(date) - $1" >> "$LOG_FILE"
}

# Function to handle errors
error() {
    log "ERROR: $1"
    exit 1
}

log "Installing doas"
if ! sudo pacman -Syyu && sudo pacman -S --needed opendoas git neofetch; then
    error "Failed to install one of "opendoas git neofetch""
fi

if [ ! -f "/etc/doas.conf" ]; then
    cat <<EOF > "/etc/doas.conf"
permit nopass :wheel
EOF
fi

log "Unlocking FRZR and updating package list..."
if ! doas -u root frzr-unlock; then
    error "Failed to unlock FRZR"
fi
# Update package list
if ! doas -u root pacman -Syyu; then
    error "Failed to update System"
fi

# Run the Steam Deck installer
log "Running Steam Deck installer..."
if ! curl -L https://github.com/SteamDeckHomebrew/decky-installer/releases/latest/download/install_release.sh | sh; then
    error "Failed to run Steam Deck installer"
fi

# Delete RetroArch thumbnails
log "Deleting RetroArch thumbnails..."
if ! rm -rf "$USER_HOME/.steam/steam/steamapps/common/RetroArch/thumbnails"; then
    error "Failed to delete RetroArch thumbnails"
fi
cd "$USER_HOME/.steam/steam/steamapps/common/RetroArch/" || error "Failed to change directory"

# Clone libretro-thumbnails repository
log "Cloning libretro-thumbnails repository..."
if ! git clone --recursive --depth=1 http://github.com/libretro-thumbnails/libretro-thumbnails.git thumbnails; then
    error "Failed to clone libretro-thumbnails repository"
fi

# Create .bash_profile file if it doesn't exist
log "Creating .bash_profile file..."
if [ ! -f "$USER_HOME/.bash_profile" ]; then
    cat <<EOF > "$USER_HOME/.bash_profile"
#!/bin/bash

# Define an alias for 'll' to run 'ls -al' for a detailed directory listing
alias ll='ls -al'
alias upgrade='sudo pacman -Syyu'

# Check if the script is being run over an SSH connection
if [ -n "\$SSH_CONNECTION" ]; then
    # If it is, run neofetch to display system information
    neofetch
    # Run the additional command
    doas -u root frzr-unlock
fi
EOF
    if ! chmod +x "$USER_HOME/.bash_profile"; then
        error "Failed to set execute permissions on .bash_profile file"
    fi
fi

log "Script completed successfully!"
