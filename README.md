# fail2ban_debian9_stretch

A Docker-based fail2ban implementation for legacy Debian 9 Stretch systems, specifically configured for protecting web applications against various types of attacks.

## Overview

This project provides a containerized fail2ban setup that protects web applications from:
- Brute force attacks
- Common web attacks
- Bot scanning
- Unauthorized access attempts
- Rails-specific security threats

## Features

- Pre-configured fail2ban rules for:
  - Nginx HTTP authentication failures
  - Bot scanning attempts
  - Rails authentication failures
  - Rails brute force attacks
  - Common web attacks
- Customizable ban times and retry limits
- Email notifications for security events
- Supervisord for process management
- SSH access for administration

## Configuration

The project includes several configuration files:
- `jail.local`: Main fail2ban configuration with ban times and retry limits
- `rails-auth.conf`: Rules for Rails authentication failures
- `rails-bruteforce.conf`: Rules for Rails brute force attempts
- `common-attacks.conf`: Rules for common web attacks
- `supervisord.conf`: Process management configuration

## Usage

1. Build and start the container:
```bash
docker-compose up --build
```

2. The container will be accessible on port 80

3. Fail2ban will automatically start protecting your application against various attacks

## Security Settings

- Default ban time: 1 hour
- Retry window: 10 minutes
- Maximum retries before ban: 5
- Custom rules for specific attack types with different thresholds

## Requirements

- Docker
- Docker Compose
- Root access (for iptables operations)

## Note

This project is specifically designed for Debian 9 Stretch and uses archive mirrors since the distribution is EOL. Use with caution in production environments.
