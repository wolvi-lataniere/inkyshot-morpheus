#!/bin/bash

# Get the current device name
export DEVICE_NAME=$(curl -sX GET "https://api.balena-cloud.com/v5/device?\$filter=uuid%20eq%20'$BALENA_DEVICE_UUID'" \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $BALENA_API_KEY" | \
jq -r ".d | .[0] | .device_name")

# Run the display update once on container start
python /usr/app/update-display.py

# Save out the current env to a file so cron job can use it
export -p > /usr/app/env.sh

# Set default values if these env vars are not set
if [[ -z "${ALTERNATE_FREQUENCY}" ]]; then
  Alternate="0"
  [[ -z "${UPDATE_HOUR}" ]] && UpdateHour='9' || UpdateHour="${UPDATE_HOUR}"
else
  Alternate="*/${ALTERNATE_FREQUENCY}"
  UpdateHour='*'
fi

# Request sleep for 1h
SLEEPTIME=${SLEEPTIME:-3600}
./morpheus.sh -a ${MORPHEUS_ADDR} -w TimeSleep ${SLEEPTIME} 

# Clean turn-off
curl -X POST --header "Content-Type:application/json" \
    "$BALENA_SUPERVISOR_ADDRESS/v1/shutdown?apikey=$BALENA_SUPERVISOR_API_KEY"

# Prevent from quitting
while :
do
  sleep 1h
done
