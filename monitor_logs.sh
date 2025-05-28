#!/bin/bash

LOG_FILE="/var/log/nginx/access.log"
ERROR_PATTERN="500"
ALERT_SCRIPT="./send_slack_alert.py"
SETUP_SCRIPT="./setup_nginx.sh"

bash "$SETUP_SCRIPT"
if [ $? -ne 0  ]; then
        echo "Aborting. nginx setup failed..."
        exit 1
else
        echo "Nginx setup done."
fi

if [ ! -f "$ALERT_SCRIPT" ]; then
        echo "Error: Alert script not found"
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: Log file $LOG_FILE not found"
    exit 1
fi


echo "Monitoring $LOG_FILE for errors..."
tail -f "$LOG_FILE" | grep --line-buffered "$ERROR_PATTERN" | while read -r line; do
    echo "Error detected: $line"
    python3 "$ALERT_SCRIPT" "$line"
done
