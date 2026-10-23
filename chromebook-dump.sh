#!/bin/bash

echo "ccd open" | tee -a /dev/ttyUSB0 > /dev/null
flashrom -p raiden_debug_spi:target=AP -r "flashrom_cromebook_dump_$(date +%Y-%m-%d_%H-%M-%S).rom"
