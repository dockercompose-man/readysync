#!/bin/bash
#set -x

## Author Michael Cabral 2024
## Title: Readystream
## GPL-3.0 license
## Description: Downloads or Mounts any HTTP repository of games using httpdirfs, wget, mount-zip, rclone, and 7-zip giving you an Online and Offline experience.
## Online = HTTP/FTP Mounted Games
## Offline = Local Hard Drive Games

ln -s /usr/bin/fusermount /usr/bin/fusermount3
mount -o remount,rw /

log_file="/recalbox/share/system/.systemstream.log"

# Clear the log file
truncate -s 0 "$log_file"

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>>"$log_file" 2>&1

sanitize_dir_name() {
  tr -cd '[:alnum:]' <<< "$1"
}

# Function to perform actions specific to Online Mode
online_mode() {
    # Add your specific actions for Online Mode here
    # ...
    echo "Performing actions specific to Online Mode..."

# Check and update systemlist.xml based on user choice
offline_systemlist="/recalbox/share_init/system/.emulationstation/systemlist.xml"
offline_backup="/recalbox/share/userscripts/.config/.emulationstation/systemlist-backup.xml"
offline_online="/recalbox/share/userscripts/.config/.emulationstation/systemlist-online.xml"
offline_offline="/recalbox/share/userscripts/.config/.emulationstation/systemlist-offline.xml"

# Online Mode
if [ -f "$offline_systemlist" ] && [ -f "$offline_online" ]; then
# Mount thumbnails with rclone
rclone mount thumbnails: /recalbox/share/thumbs --config=/recalbox/share/system/rclone.conf --http-no-head --no-checksum --no-modtime --attr-timeout 365d --dir-cache-time 365d --poll-interval 365d --allow-non-empty --daemon --no-check-certificate
# Mount thumbnails2 with rclone
#rclone mount thumbnails2: /recalbox/share/thumbs2 --config=/recalbox/share/system/rclone2.conf --http-no-head --no-checksum --no-modtime --attr-timeout 365d --dir-cache-time 365d --poll-interval 365d --allow-non-empty --daemon --no-check-certificate
# Mount videos with rclone
#rclone mount videos: /recalbox/share/videos --config=/recalbox/share/system/rclone3.conf --http-no-head --no-checksum --no-modtime --attr-timeout 365d --dir-cache-time 365d --poll-interval 365d --allow-non-empty --daemon --no-check-certificate

# Mount Myrient to recalbox/share/rom
httpdirfs -f -o debug -o auto_unmount --cache --cache-location=/recalbox/share/system/.cache/httpdirfs --dl-seg-size=1 --max-conns=20 #--retry-wait=1 -o nonempty "https://myrient.erista.me/files/" "/recalbox/share/rom/"

# Mount The-Eye to recalbox/share/rom2
#httpdirfs -f -o debug -o auto_unmount --cache --cache-location=/recalbox/share/system/.cache/httpdirfs --dl-seg-size=1 --max-conns=20 #--retry-wait=1 -o nonempty "https://the-eye.eu/public/" "/recalbox/share/rom2/"

# Mount The-Eye to recalbox/share/rom3
#httpdirfs -f -o debug -o auto_unmount --cache --cache-location=/recalbox/share/system/.cache/httpdirfs --dl-seg-size=1 --max-conns=20 --retry-wait=1 -o nonempty "ftp://oscollect:SxrRwRGbMe50XcwMKB53j6LSN9DehYMJag@old-dos.ru/" "/recalbox/share/rom3/"



	# Backup the existing systemlist.xml
    echo "Backing up systemlist.xml..."
    cp "$offline_systemlist" "$offline_backup"
    echo "Backup created: $offline_backup"

    # Overwrite systemlist.xml with the online version
    echo "Overwriting systemlist.xml with the online version..."
    cp "$offline_online" "$offline_systemlist"
    echo "Online version applied."
fi

# Read the roms array from platforms.txt
platforms_file="/recalbox/share/userscripts/.config/readystream/platforms.txt"
mapfile -t roms < "$platforms_file"

# Specify the temporary destination path for zip files
destination_path_zip_temp="/recalbox/share/zip"

# Loop through the roms array for normal files
for rom_entry in "${roms[@]}"; do
    # Remove roms+=(" from the beginning of the entry
    rom_entry="${rom_entry#roms+=(\"}"

    # Split the entry into components
    IFS=';' read -r -a rom_data <<< "$rom_entry"

    # Extract console name (first name in the array)
    console_name="${rom_data[0]}"

    # Extract console directory
    console_directory="${rom_data[1]}"

done


# Function to create console directory
create_console_directory() {
  local console_name="$1"
  console_name="${console_name//\/}"  # This removes trailing slashes
  mkdir -p "/recalbox/share/userscripts/.config/readystream/roms/$console_name"
  mkdir -p "/recalbox/share/roms/readystream/$console_name"

}

# Extract console names from platforms.txt using awk
console_names=$(awk -F';' '/^roms\+=/{gsub(/roms\+=\("/, ""); gsub(/".*/, ""); print $1}' /recalbox/share/userscripts/.config/readystream/platforms.txt)

# Display extracted console names for debugging
echo "Console names extracted from platforms.txt: '$console_names'"

# Loop through extracted console names and create directories
IFS=$'\n'  # Set Internal Field Separator to newline to handle multiple console names
for console_name in $console_names; do
  # Use the extracted console name to create the console directory
  create_console_directory "$console_name"

done
}

# Function to perform actions specific to Offline Mode
offline_mode() {
    # Add your specific actions for Offline Mode here
    # ...
    echo "Performing actions specific to Offline Mode..."

# Check and update systemlist.xml based on user choice
offline_systemlist="/recalbox/share_init/system/.emulationstation/systemlist.xml"
offline_backup="/recalbox/share/userscripts/.config/.emulationstation/systemlist-backup.xml"
offline_online="/recalbox/share/userscripts/.config/.emulationstation/systemlist-online.xml"
offline_offline="/recalbox/share/userscripts/.config/.emulationstation/systemlist-offline.xml"
	
# Offline Mode
if [ "$mode_choice" != "1" ]; then
    if [ -f "$offline_systemlist" ] && [ -f "$offline_offline" ]; then
        # Backup existing systemlist.xml
        echo "Backing up systemlist.xml..."
        cp "$offline_systemlist" "$offline_backup"
        echo "Backup created: $offline_backup"

        # Overwrite systemlist.xml with offline version
        echo "Overwriting systemlist.xml with offline version..."
        cp "$offline_offline" "$offline_systemlist"
        echo "Offline version applied."

        # Replace the following line with your specific actions for Offline Mode
        echo "Performing actions specific to Offline Mode..."
        # ...

        echo "Installation complete. Log saved to: $log_file"

        # Replace the following line with the actual command to start emulation station
        chvt 1; es start
    else
        echo "Error: systemlist.xml files not found."
    fi
fi	
	
}

# Detect architecture
case $(uname -m) in
  x86_64) sevenzip_arch="x64"; rclone_arch="amd64"; mount_zip_arch="x64" ;;
  aarch64) sevenzip_arch="arm64"; rclone_arch="arm64"; mount_zip_arch="arm64" ;;
  *) echo "Unsupported architecture."; exit 1 ;;
esac

# Download and Install 7zip
if [ ! -f /usr/bin/7za ]; then
  echo "Downloading and installing 7zip..."
  wget -O /usr/bin/7za https://github.com/develar/7zip-bin/raw/master/linux/${sevenzip_arch}/7za
  chmod +x /usr/bin/7za
  echo "7zip installed successfully."
else
  echo "7zip is already installed."
fi

# Download and Install rclone
if [ ! -f /usr/bin/rclone ]; then
  echo "Downloading and installing rclone..."
  wget -O /usr/bin/rclone.zip https://downloads.rclone.org/v1.65.0/rclone-v1.65.0-linux-${rclone_arch}.zip
  7za e -y /usr/bin/rclone.zip
  mv rclone /usr/bin
  chmod +x /usr/bin/rclone
  rm /usr/bin/rclone.zip
  echo "rclone installed successfully."
else
  echo "rclone is already installed."
fi

# Download and Install jq 1.7.1
if [ ! -f /usr/bin/jq ]; then
  echo "Downloading jq 1.7.1..."

  # Detect the architecture
  case $(arch) in
    x86_64) jq_arch="amd64" ;;
    aarch64) jq_arch="arm64" ;;
    *) echo "Unsupported jq architecture: $(arch)."; exit 1 ;;
  esac

  jq_url="https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-${jq_arch}"

  # Download and Install jq
  wget -O /usr/bin/jq ${jq_url}
  chmod +x /usr/bin/jq

  echo "jq 1.7.1 installed successfully for architecture: ${jq_arch}."
else
  echo "jq 1.7.1 is already installed."
fi

# Download and Install mount-zip
if [ ! -f /usr/bin/mount-zip ]; then
  echo "Downloading mount-zip..."

  # Detect the architecture
  case $(arch) in
    x86_64) mount_zip_arch="x64" ;;
    aarch64) mount_zip_arch="arm64" ;;
    *) echo "Unsupported mount-zip architecture: $(arch)."; exit 1 ;;
  esac

  mount_zip_url="https://github.com/readycade/readysync/raw/master/share/userscripts/.config/readystream/mount-zip-${mount_zip_arch}/mount-zip"

  # Download and Install mount-zip
  wget -O /usr/bin/mount-zip ${mount_zip_url}
  chmod +x /usr/bin/mount-zip

  echo "mount-zip installed successfully for architecture: ${mount_zip_arch}."
else
  echo "mount-zip is already installed."
fi

# Download and Install httpdirfs
if [ ! -f /usr/bin/httpdirfs ]; then
  echo "Downloading httpdirfs..."

  # Detect the architecture
  case $(arch) in
    x86_64) httpdirfs_arch="x64" ;;
    aarch64) httpdirfs_arch="arm64" ;;
    *) echo "Unsupported httpdirfs architecture: $(arch)."; exit 1 ;;
  esac

  httpdirfs_url="https://github.com/readycade/readysync/raw/master/share/userscripts/.config/readystream/httpdirfs-${httpdirfs_arch}/httpdirfs"

  # Download and Install httpdirfs
  wget -O /usr/bin/httpdirfs ${httpdirfs_url}
  chmod +x /usr/bin/httpdirfs

  echo "httpdirfs installed successfully for architecture: ${httpdirfs_arch}."
else
  echo "httpdirfs is already installed."
fi

# Download rclone.conf if it doesn't exist
if [ ! -e /recalbox/share/userscripts/.config/readystream/rclone.conf ]; then
    mkdir -p /recalbox/share/userscripts/.config/readystream
    wget -O /recalbox/share/userscripts/.config/readystream/rclone.conf https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/readystream/rclone.conf
    echo "rclone.conf downloaded to /recalbox/share/userscripts/.config/readystream/ successfully."
fi

# Copy rclone.conf to /recalbox/share/system/ if it doesn't exist there
if [ ! -e /recalbox/share/system/rclone.conf ]; then
    cp /recalbox/share/userscripts/.config/readystream/rclone.conf /recalbox/share/system/
    echo "rclone.conf copied to /recalbox/share/system/ successfully."
else
    echo "rclone.conf already exists in /recalbox/share/system/. No need to copy."
fi

# Download rclone2.conf if it doesn't exist
if [ ! -e /recalbox/share/userscripts/.config/readystream/rclone2.conf ]; then
    mkdir -p /recalbox/share/userscripts/.config/readystream
    wget -O /recalbox/share/userscripts/.config/readystream/rclone2.conf https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/readystream/rclone2.conf
    echo "rclone2.conf downloaded to /recalbox/share/userscripts/.config/readystream/ successfully."
fi

# Copy rclone2.conf to /recalbox/share/system/ if it doesn't exist there
if [ ! -e /recalbox/share/system/rclone2.conf ]; then
    cp /recalbox/share/userscripts/.config/readystream/rclone2.conf /recalbox/share/system/
    echo "rclone2.conf copied to /recalbox/share/system/ successfully."
else
    echo "rclone2.conf already exists in /recalbox/share/system/. No need to copy."
fi

# Download rclone3.conf if it doesn't exist
if [ ! -e /recalbox/share/userscripts/.config/readystream/rclone3.conf ]; then
    mkdir -p /recalbox/share/userscripts/.config/readystream
    wget -O /recalbox/share/userscripts/.config/readystream/rclone3.conf https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/readystream/rclone3.conf
    echo "rclone3.conf downloaded to /recalbox/share/userscripts/.config/readystream/ successfully."
fi

# Copy rclone3.conf to /recalbox/share/system/ if it doesn't exist there
if [ ! -e /recalbox/share/system/rclone3.conf ]; then
    cp /recalbox/share/userscripts/.config/readystream/rclone3.conf /recalbox/share/system/
    echo "rclone3.conf copied to /recalbox/share/system/ successfully."
else
    echo "rclone3.conf already exists in /recalbox/share/system/. No need to copy."
fi

# Download platforms.txt if it doesn't exist in /recalbox/share/userscripts/.config/readystream/
if [ ! -e /recalbox/share/userscripts/.config/readystream/platforms.txt ]; then
    mkdir -p /recalbox/share/userscripts/.config/readystream
    wget -O /recalbox/share/userscripts/.config/readystream/platforms.txt https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/readystream/platforms.txt
    echo "platforms.txt downloaded to /recalbox/share/userscripts/.config/readystream/ successfully."
fi

# Check if files already exist in /recalbox/share/userscripts/.config/.emulationstation/
if [ -e /recalbox/share/userscripts/.config/.emulationstation/systemlist-backup.xml ] && \
   [ -e /recalbox/share/userscripts/.config/.emulationstation/systemlist-online.xml ] && \
   [ -e /recalbox/share/userscripts/.config/.emulationstation/systemlist-offline.xml ]; then
    echo "Files already exist. No need to download."
else
    # Download systemlist-backup.xml
    mkdir -p /recalbox/share/userscripts/.config/.emulationstation/

    wget -O /recalbox/share/userscripts/.config/.emulationstation/systemlist-backup.xml https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/.emulationstation/systemlist-backup.xml

    # Download systemlist-online.xml
    wget -O /recalbox/share/userscripts/.config/.emulationstation/systemlist-online.xml https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/.emulationstation/systemlist-online.xml

    # Download systemlist-offline.xml
    wget -O /recalbox/share/userscripts/.config/.emulationstation/systemlist-offline.xml https://raw.githubusercontent.com/readycade/readysync/master/share/userscripts/.config/.emulationstation/systemlist-offline.xml

    # Check if files were downloaded successfully
    if [ -e /recalbox/share/userscripts/.config/.emulationstation/systemlist-backup.xml ] && \
       [ -e /recalbox/share/userscripts/.config/.emulationstation/systemlist-online.xml ] && \
       [ -e /recalbox/share/userscripts/.config/.emulationstation/systemlist-offline.xml ]; then
        echo "Files downloaded successfully."
    else
        echo "Failed to download one or more files."
    fi
fi

# Check if /recalbox/share/userscripts/.config/readystream/roms is empty
if [ -z "$(ls -A /recalbox/share/userscripts/.config/readystream/roms)" ]; then
    echo "Downloading gamelist.xml and checksums for ALL Consoles..."
    mkdir -p /recalbox/share/userscripts/.config/readystream/roms
    wget --recursive --no-parent -P /recalbox/share/userscripts/.config/readystream/roms https://github.com/readycade/readysync/tree/master/share/userscripts/.config/readystream/roms
    echo "gamelist.xml and checksums downloaded successfully."
else
    echo "gamelist.xml and checksums directory is not empty. No need to download."
fi

# If directories don't exist, create them
if [ ! -d /recalbox/share/roms/readystream ]; then
    mkdir -p /recalbox/share/roms/readystream
    echo "Directory /recalbox/share/roms/readystream created successfully."
else
    echo "Directory /recalbox/share/roms/readystream already exists. No need to create."
fi

if [ ! -d /recalbox/share/rom ]; then
    mkdir -p /recalbox/share/rom
    echo "Directory /recalbox/share/rom created successfully."
else
    echo "Directory /recalbox/share/rom already exists. No need to create."
fi

if [ ! -d /recalbox/share/rom2 ]; then
    mkdir -p /recalbox/share/rom2
    echo "Directory /recalbox/share/rom2 created successfully."
else
    echo "Directory /recalbox/share/rom2 already exists. No need to create."
fi

if [ ! -d /recalbox/share/rom3 ]; then
    mkdir -p /recalbox/share/rom3
    echo "Directory /recalbox/share/rom3 created successfully."
else
    echo "Directory /recalbox/share/rom3 already exists. No need to create."
fi

if [ ! -d /recalbox/share/rom4 ]; then
    mkdir -p /recalbox/share/rom4
    echo "Directory /recalbox/share/rom4 created successfully."
else
    echo "Directory /recalbox/share/rom4 already exists. No need to create."
fi

if [ ! -d /recalbox/share/thumbs ]; then
    mkdir -p /recalbox/share/thumbs
    echo "Directory /recalbox/share/thumbs created successfully."
else
    echo "Directory /recalbox/share/thumbs already exists. No need to create."
fi

if [ ! -d /recalbox/share/thumbs2 ]; then
    mkdir -p /recalbox/share/thumbs2
    echo "Directory /recalbox/share/thumbs2 created successfully."
else
    echo "Directory /recalbox/share/thumbs2 already exists. No need to create."
fi

if [ ! -d /iso ]; then
    mkdir -p /iso
    echo "Directory /iso created successfully."
else
    echo "Directory /iso already exists. No need to create."
fi

if [ ! -d /recalbox/share/zip ]; then
    mkdir -p /recalbox/share/zip
    echo "Directory /recalbox/share/zip created successfully."
else
    echo "Directory /recalbox/share/zip already exists. No need to create."
fi

# Function to toggle a platform in the array
toggle_platform() {
    local platform_name=$1
    local action=$2

    case $action in
        "enable")
            sed -i "/^#roms+=(\"$platform_name;/ s/^#//" "/recalbox/share/userscripts/.config/readystream/platforms.txt"
            ;;
        "disable")
            sed -i "/^roms+=(\"$platform_name;/ s/^/#/" "/recalbox/share/userscripts/.config/readystream/platforms.txt"
            ;;
        *)
            echo "Invalid action. Use 'enable' or 'disable'."
            ;;
    esac
}

# List of platforms and their status (1 for enabled, 0 for disabled)
platforms=(
    # No-Intro Romsets
    "arduboy 1"
    "atari2600 1"
    "atari5200 1"
    "atari7800 1"
    "atarist 1"
    "jaguar 0"
    "lynx 0"
    "wswan 0"
    "wswanc 0"
    "colecovision 0"
    "c64 0"
    "cplus4 0"
    "vic20 0"
    "scv 0"
    "channelf 0"
    "vectrex 0"
    "o2em 0"
    "intellivision 0"
    "msx1 0"
    "msx2 0"
    "pcengine 0"
    "supergrafx 0"
    "fds 0"
    "gb 0"
    "gbc 0"
    "gba 0"
    "n64 0"
    "nes 0"
    "pokemini 0"
    "satellaview 0"
    "sufami 0"
    "snes 0"
    "virtualboy 0"
    "videopacplus 0"
    "ngp 0"
    "ngpc 0"
    "sega32x 0"
    "gamegear 0"
    "sg1000 0"
    "mastersystem 0"
    "megadrive 0"
    "pico 0"
    "supervision 0"
    "pcv2 0"
    "palm 0"
    "gw 0"
    "64dd 0"
    "nds 0"
    # Redump Romsets (CD/DVD BASED) (WARNING: these are VERY large!)
    "amigacd32 0"
    "amigacdtv 0"
    "amiga1200 0"
    "gamecube 0"
    "wii 0"
    "3do 0"
    "cdi 0"
    "pcenginecd 0"
    "neogeocd 0"
    "dreamcast 0"
    "segacd 0"
    "saturn 0"
    "psx 0"
    "ps2 0"
    "psp 0"
    "pcfx 0"
    "naomi 0"
    "jaguar 0"
    # TOSEC Romsets
    "amstradcpc 0"
    "atari800 0"
    "pet 0"
    "pc88 0"
    "pc98 0"
    "pcengine 0"
    "zxspectrum 0"
    "zx81 0"
    "x1 0"
    "x68000 0"
    "gx4000 0"
    "macintosh 0"
    "apple2gs 0"
    "apple2 0"
    "amiga1200 0"
    "bk 0"
    "msx1 0"
    # MSX 2
    "msx2 0"
    # MSX 2+
    "msx2 0"
    "msxturbor 0"
    # Old-DOS Romsets
    "dos 0"
    # Add more platforms as needed
)

    # Experimental (DO NOT USE)
    #"analogue 0"
    #"triforce 0"
    #"amiga1200 0"
    
    # No Intro Experimental (DO NO USE)
    # New Nintendo 3DS
    #"3ds 0"
    # Nintendo 3DS
    #"3ds 0"

    # Redump Experimental (DO NOT USE)
    #"naomi 0"
    #"xbox 0"
    #"xbox360 0"
    #"ps3 0"
    #"ps3keys 0"
    #"ps3keystxt 0"

# Loop through platforms
for platform_info in "${platforms[@]}"; do
    platform_name=$(echo "$platform_info" | cut -d ' ' -f 1)
    platform_status=$(echo "$platform_info" | cut -d ' ' -f 2)

    case $platform_status in
        1)
            toggle_platform "$platform_name" "enable"
            ;;
        0)
            toggle_platform "$platform_name" "disable"
            delete_disabled_platform_directory "$platform_name"
            ;;
        *)
            echo "Invalid status. Use '1' for enable and '0' for disable."
            ;;
    esac
done

# Display menu
echo "Please select a mode:"
echo "1. Online Mode"
echo "2. Offline Mode"

# Capture input with timeout
timeout_seconds=5
read -t "$timeout_seconds" -r input || mode_choice="1"

# Determine the mode based on user input or timeout
case "$mode_choice" in
    "1")
		# Online Mode
        online_mode
        ;;
    "2")
        # Offline Mode
        offline_mode
        ;;
    *)
        echo "Invalid choice: $mode_choice"
        ;;
esac

chvt 1; es start

exit