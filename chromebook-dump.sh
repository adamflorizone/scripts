#!/bin/bash
# curl -fsSL https://raw.githubusercontent.com/adamflorizone/scripts/refs/heads/main/chromebook-dump.sh | sh

if [ "$EUID" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

echo "ccd open" | tee -a /dev/ttyUSB0 > /dev/null
sleep 5
flashrom -p raiden_debug_spi:target=AP -r "flashrom_cromebook_dump_$(date +%Y-%m-%d_%H-%M-%S).rom"
