#!/bin/bash

set -e

echo "DHIS2 Security Reporting Setup"
echo "================================"

if ! command -v ansible-playbook &> /dev/null; then
    echo "Error: Ansible is not installed"
    exit 1
fi

# Get Telegram credentials
read -p "Enter Telegram Bot Token: " BOT_TOKEN
read -p "Enter Telegram Chat ID: " CHAT_ID
read -p "Enter alert time (HH:MM) [07:00]: " ALERT_TIME
ALERT_TIME=${ALERT_TIME:-07:00}

if ! [[ "$ALERT_TIME" =~ ^[0-2][0-9]:[0-5][0-9]$ ]]; then
    echo "Error: Invalid time format. Please use HH:MM (e.g., 07:00, 21:45)"
    exit 1
fi

if [[ -z "$BOT_TOKEN" ]] || [[ -z "$CHAT_ID" ]]; then
    echo "Error: Bot token and chat ID are required"
    exit 1
fi

ansible-playbook playbook.yml \
  -e "bot_token=$BOT_TOKEN" \
  -e "chat_id=$CHAT_ID" \
  -e "alert_time_input=$ALERT_TIME" \
  --ask-become-pass

echo "Setup complete. Security reports will be sent daily at $ALERT_TIME"