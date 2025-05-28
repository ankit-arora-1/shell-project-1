import requests
import sys
from datetime import datetime

# Configuration
SLACK_WEBHOOK_URL = "SLACK_WEBHOOK_URL"

def send_slack_alert(error_line):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = {
        "text": f":warning: *Error Detected in Logs* :warning:\n*Time*: {timestamp}\n*Details*: {error_line}"
    }
    try:
        response = requests.post(SLACK_WEBHOOK_URL, json=message)
        if response.status_code == 200:
            print("Slack alert sent successfully")
        else:
            print(f"Failed to send Slack alert: {response.status_code} - {response.text}")
    except requests.RequestException as e:
        print(f"Error sending Slack alert: {e}")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        error_line = sys.argv[1]
        send_slack_alert(error_line)
    else:
        print("Error: No error line provided")
