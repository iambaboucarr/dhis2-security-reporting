# DHIS2 Security Reporting

## Quick Setup

1. **Get Telegram Bot Credentials:**

   - Create bot with [@BotFather](https://t.me/botfather)
   - Get bot token
   - Get chat ID from: `https://api.telegram.org/bot<TOKEN>/getUpdates`

2. **Run Playbook:**
   ```bash
   ansible-playbook playbook.yml \
     -e "bot_token=YOUR_TOKEN" \
     -e "chat_id=YOUR_CHAT_ID"
   ```

## What It Monitors

### Container: `proxy` (Nginx)

- **Access Log**: `/var/log/nginx/access.log`
  - HTTP 4xx/5xx errors
  - SQL injection attempts
  - XSS attempts
- **Error Log**: `/var/log/nginx/error.log`
  - Critical errors and alerts

### Container: `dhis`/`Custom container name` (DHIS2 Application)

- **Tomcat Logs**: Via `journalctl -u tomcat9` (Ubuntu 22.04) or `journalctl -u tomcat10` (Ubuntu 24.04)
  - Auto-detects tomcat version
  - Authentication failures
  - Unauthorized access attempts
  - Application errors and exceptions
- **DHIS2 Logs**: `/opt/dhis2/logs/*.log` (if exists)
  - Additional application-specific logs

### Container: `postgres` (PostgreSQL)

- **PostgreSQL Logs**: `/var/log/postgresql/*.log`
  - Authentication errors
  - Permission denied events
  - Fatal errors
- **Journal**: `journalctl -u postgresql`
  - Additional database events

### System Health

- Container status (RUNNING/STOPPED)
- Disk usage (alert if >80%)
- Failed systemd services
- DHIS2 configuration file existence

## Alert Schedule

- **Daily Report**: 07:00 (configurable)
- **Hourly Check**: Critical errors only (>50 errors)

## Manual Check

```bash
sudo /opt/security-monitor/security-check.sh
```

## Key Features

- Monitors via `lxc exec` commands
- Uses `journalctl` for tomcat logs (as per dhis2-logview)
- Version-agnostic PostgreSQL log checking
- Minimal dependencies (logwatch, curl, jq)

## Files Created

- `/opt/security-monitor/security-check.sh` - Main monitoring script
- `/opt/security-monitor/send-telegram.sh` - Telegram sender
- Cron jobs for automated checks

## Customization

Edit thresholds in the playbook:

- Failed login threshold: Line 84 (default: 10)
- Hourly error threshold: Line 158 (default: 50)

## Compatibility

Tested with:

- dhis2-server-tools standard deployment
- Ubuntu 22.04/24.04
- LXD containers
- DHIS2 versions 2.38+

## Uninstall

```bash
sudo rm -rf /opt/security-monitor
sudo crontab -l | grep -v "DHIS2" | sudo crontab -
```
