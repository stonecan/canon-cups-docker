#!/bin/bash

PRINTER_MODEL=HL-L2300D

# Stop Container (if running)
echo "Stopping current container..."
/usr/bin/docker stop cups-docker
/usr/bin/docker rm cups-docker

# Get Printer address on host, ex : /dev/bus/usb/002/008
echo "Getting printer info..."
PRINTER_BUS=$(/usr/bin/lsusb | grep Brother | awk '{print $2}')
PRINTER_DEV=$(/usr/bin/lsusb | grep Brother | awk '{print $4}')
PRINTER_DEV="${PRINTER_DEV%?}"
echo "${PRINTER_BUS}"
echo "${PRINTER_DEV}"
if [[ ! -z ${PRINTER_BUS+x} && ! -z ${PRINTER_DEV+x} ]];  then
        PRINTER_ADDRESS="/dev/bus/usb/${PRINTER_BUS}/${PRINTER_DEV}"
fi

# Run docker container if Brother printer is found
if [ -z ${PRINTER_ADDRESS+x} ]; then
        echo "Brother printer cannot be found, cannot run container";
else
        echo "Running container for Brother printer ${PRINTER_MODEL} at address ${PRINTER_ADDRESS}..."
        exec /usr/bin/docker run -d \
--name cups-docker \
-e CUPS_USER_ADMIN=admin \
-e CUPS_USER_PASSWORD=secr3t \
-e PRINTER_MODEL=${PRINTER_MODEL} \
-p 631:631/tcp \
-v /path/to/cupsd.conf:/etc/cups/cupsd.conf \
--device=${PRINTER_ADDRESS} \
monkeydri/cups-docker:latest
fi

exit 0