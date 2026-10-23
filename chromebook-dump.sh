#!/bin/bash

# Exit immediately if a command fails
set -e

# ==============================================================================
# 1. Privilege Escalation
# ==============================================================================
# Ensure the script is running as root, which is required for accessing 
# /dev/ttyUSB0 and executing flashrom.
if [ "$EUID" -ne 0 ]; then
  echo "Elevating privileges..."
  exec sudo "$0" "$@"
fi

# ==============================================================================
# 2. Unlock Closed Case Debugging (CCD)
# ==============================================================================
# Send the 'ccd open' command to the Cr50/Ti50 security chip via the SuzyQable.
# Note: If the device is locked, this will trigger a physical presence check 
# requiring manual power button presses, which takes longer than 5 seconds.
echo "Sending 'ccd open' command to /dev/ttyUSB0..."
echo "ccd open" | tee -a /dev/ttyUSB0 > /dev/null
sleep 5

# ==============================================================================
# 3. Dump Firmware (ROM)
# ==============================================================================
# Generate a timestamped base filename and read the Application Processor (AP) 
# firmware using flashrom over the debug cable.
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
filename="chromebook_dump_${timestamp}"

echo "Dumping firmware to ${filename}.rom..."
flashrom -p raiden_debug_spi:target=AP -r "${filename}.rom"

# ==============================================================================
# 4. Fetch Extraction Utilities (Idempotent)
# ==============================================================================
# Check if cbfstool exists locally; if not, download and extract it.
if [ ! -f "./cbfstool" ]; then
    echo "Downloading cbfstool..."
    wget -q https://mrchromebox.tech/files/util/cbfstool.tar.gz
    tar -zxf cbfstool.tar.gz
fi

# Check if gbb_utility exists locally; if not, download and extract it.
if [ ! -f "./gbb_utility" ]; then
    echo "Downloading gbb_utility..."
    wget -q https://mrchromebox.tech/files/util/gbb_utility.tar.gz
    tar -zxf gbb_utility.tar.gz
fi

# ==============================================================================
# 5. Extract Hardware Data
# ==============================================================================
# Extract the Read-Only Vital Product Data (RO_VPD) region, which contains 
# the serial number, MAC address, and enterprise enrollment data.
echo "Extracting RO_VPD to ${filename}.vpd.bin..."
./cbfstool "${filename}.rom" read -r RO_VPD -f "${filename}.vpd.bin"

# Extract the Hardware ID from the Google Binary Block (GBB) and strip the 
# "hardware_id: " prefix to leave just the raw ID string.
echo "Extracting HWID to ${filename}.hwid.txt..."

# DOCS ARE WRONG:
# ./gbb_utility "${filename}.rom" --get --hwid | sed 's/^hardware_id: //' > "${filename}.hwid.txt"

# THIS WORKS!
./cbfstool "${filename}.rom" extract -n hwid -f "${filename}.hwid.txt"

# ==============================================================================
# 6. Download Full ROM (Custom Coreboot)
# ==============================================================================
# Extract the board name (the first word of the HWID) to pass to the script.
BOARD=$(awk '{print $1}' "${filename}.hwid.txt")

echo "Downloading Full ROM for board: ${BOARD}..."

if [ ! -f "./download-fullrom.sh" ]; then
    wget -q https://raw.githubusercontent.com/MrChromebox/scripts/main/download-fullrom.sh
    chmod +x download-fullrom.sh
fi

# Execute the script and capture its output into a variable
DL_OUTPUT=$(./download-fullrom.sh "${BOARD}")

# Echo the output so you can still see the download progress and status
echo "$DL_OUTPUT"

# Parse the output to extract the directory and the filename
ROM_DIR=$(echo "$DL_OUTPUT" | grep "^Output:" | awk '{print $2}')
ROM_FILE=$(echo "$DL_OUTPUT" | grep "^ok:" | awk '{print $2}')

# Combine them into the final path variable
ROM_PATH="${ROM_DIR}/${ROM_FILE}"

cp "${ROM_PATH}" restore.rom
./cbfstool restore.rom write -r RO_VPD -f "${filename}.vpd.bin"
./cbfstool restore.rom add -n hwid -f "${filename}.hwid.txt" -t raw

echo run this: 
echo     echo "ccd open" | sudo tee -a /dev/ttyUSB0 > /dev/null
echo     sudo flashrom -p raiden_debug_spi:target=AP -w restore.rom --ifd -i bios -N


# Verify the variable was created successfully
echo "The ROM path has been saved to the variable: ${ROM_PATH}"

echo "Process complete. Files generated:"
echo " - ${filename}.rom"
echo " - ${filename}.vpd.bin"
echo " - ${filename}.hwid.txt"
