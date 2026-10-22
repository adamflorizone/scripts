#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (e.g., sudo ./ccd_reset.sh)"
  exit 1
fi

gsctool -a -o

# Loop through all ttyUSB ports
for port in /dev/ttyUSB*; do
    # Skip if no ports are actually found
    if [ ! -e "$port" ]; then
        echo "No /dev/ttyUSB ports found."
        exit 1
    fi

    echo "Applying commands to $port..."
    echo "wp disable" > "$port"
    echo "wp disable atboot" > "$port"
    # echo "ccd reset factory" > "$port"

    echo "Finished processing $port."
done

echo sleep 5
sleep 5

curl -LOf https://mrchromebox.tech/firmware-util.sh 
bash firmware-util.sh
