# smack 🧨

> **Write safer, cleaner bash scripts in half the time**

A battle-tested Bash utility library that eliminates boilerplate, prevents common pitfalls, and makes your scripts production-ready from day one.

[![Shellcheck](https://img.shields.io/badge/shellcheck-passing-brightgreen)](https://github.com/trentas/smack)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-5.0%2B-blue)](https://www.gnu.org/software/bash/)
[![Security Hardened](https://img.shields.io/badge/security-hardened-success)](SECURITY_FIXES.md)

---

## Why smack?

### The Problem 😫

Writing production-ready bash scripts is **harder than it should be**:

```bash
# Typical bash script problems:
❌ Passwords visible in process lists
❌ SQL injection vulnerabilities
❌ No proper error handling
❌ Inconsistent logging
❌ Copy-paste boilerplate everywhere
❌ Race conditions with concurrent runs
❌ No input validation
```

### The Solution ✨

**smack** gives you battle-tested tools so you can focus on **what** your script does, not **how**:

```bash
#!/usr/bin/env smack

# That's it! Now you have:
✅ Secure database operations (no passwords in process lists)
✅ SQL injection prevention (automatic input sanitization)
✅ Professional logging (with colors, emojis, syslog)
✅ Process lifecycle management (PID files, cleanup handlers)
✅ Input validation (YAML, email, database inputs)
✅ Zero dependencies (pure bash, works everywhere)
```

---

## 🎯 Quick Start

### Installation

```bash
git clone https://github.com/trentas/smack.git
cd smack
make install
```

### Your First Script

Create `hello.sksh`:

```bash
#!/usr/bin/env smack

s.check.os                           # Verify supported OS
s.print.log info "Hello, smack! 👋"  # Beautiful logging
s.print.log notice "Processing..."   # With colors and emojis
s.process.run ls -la                 # Run commands with logging
```

Run it:

```bash
chmod +x hello.sksh
./hello.sksh
```

Output:
```
INFO   hello.sksh:main:4 Hello, smack! 👋
NOTICE hello.sksh:main:5 Processing...
DEBUG  hello.sksh:main:6 running: ls -la
```

---

## 🚀 Features

### 🔒 Security First

- **SQL Injection Prevention**: Automatic input validation for database operations
- **Secure Password Handling**: Uses environment variables, never exposes passwords in process lists
- **YAML Injection Prevention**: Validates YAML files before parsing to prevent code injection
- **Command Injection Protection**: Email subjects and user inputs are sanitized
- **100% Shellcheck Compliant**: Zero warnings, zero errors, professional code quality

### 📊 Professional Logging

```bash
s.print.log debug "Debugging information"      # 🔍 Purple
s.print.log info "Something happened"          # 💎 Blue  
s.print.log notice "Pay attention to this"     # 🔶 Green
s.print.log warn "Warning message"             # ⚠️  Yellow
s.print.log error "Something went wrong"       # ❌ Red
```

- Automatic syslog integration
- Colorful terminal output
- Function call tracking with line numbers
- Configurable log levels

### 🗄️ Database Management

```bash
# Secure MySQL operations (MySQL 5.7, 8.0+)
s.db.create.database mysql localhost "$ROOT_PASS" "myapp_db"
s.db.create.user mysql localhost "$ROOT_PASS" "app_user" "$USER_PASS"
s.db.set.grants mysql localhost "$ROOT_PASS" "myapp_db" "app_user" "ALL PRIVILEGES"

# All inputs are validated to prevent SQL injection
# Passwords never appear in process lists
```

### 🔄 Process Management

```bash
#!/usr/bin/env smack

s.process.single  # Ensure only one instance runs at a time

# Your script logic here
s.process.run "backup-database.sh"
s.process.run "compress-logs.sh"

# Cleanup happens automatically on exit (even on errors!)
```

### 📧 Integrations

```bash
# Send Slack notifications
s.print.slack info "Deployment started! 🚀"
s.print.slack error "Build failed! ❌"

# Send emails  
echo "Report attached" | s.email.send "Daily Report"

# Load configuration from YAML
s.load.yaml config.yaml  # Variables exported with s_config_ prefix
```

### ⚙️ Configuration Management

```yaml
# config.yaml
database:
  host: localhost
  name: production
slack:
  url: https://hooks.slack.com/...
  channel: "#alerts"
```

```bash
#!/usr/bin/env smack

s.load.yaml config.yaml

# Now you have:
# $s_config_database_host = "localhost"
# $s_config_database_name = "production"
# $s_config_slack_url = "https://..."
# $s_config_slack_channel = "#alerts"
```

---

## 📚 Real-World Examples

### Database Backup Script

```bash
#!/usr/bin/env smack

s.process.single                    # Only one backup at a time
s.check.root                        # Must run as root
s.load.yaml /etc/backup-config.yaml

BACKUP_FILE="/backups/db-$(date +%Y%m%d).sql.gz"

s.print.log info "Starting database backup..."
s.print.slack info "📦 Database backup started"

if s.process.run mysqldump "$DB_NAME" | gzip > "$BACKUP_FILE"; then
    SIZE=$(s.print.human_readable $(stat -f%z "$BACKUP_FILE"))
    s.print.log info "Backup complete: $SIZE"
    s.print.slack info "✅ Backup complete: $SIZE"
else
    s.print.log error "Backup failed!"
    s.print.slack error "❌ Backup failed!"
    exit 1
fi
```

### Application Deployment Script

```bash
#!/usr/bin/env smack

s.process.single
s.check.requirements? git docker docker-compose

s.print.log info "Deploying application..."
s.print.slack info "🚀 Deployment started"

# Pull latest code
s.process.run git pull origin main

# Generate secure database password
DB_PASS=$(s.print.password 32)

# Set up database
s.db.create.database mysql localhost "$ROOT_PASS" "app_prod"
s.db.create.user mysql localhost "$ROOT_PASS" "app_user" "$DB_PASS"
s.db.set.grants mysql localhost "$ROOT_PASS" "app_prod" "app_user" "ALL PRIVILEGES"

# Deploy
s.process.run docker-compose up -d

s.print.log info "Deployment complete! 🎉"
s.print.slack info "✅ Deployment successful!"
```

### System Health Check

```bash
#!/usr/bin/env smack

s.check.requirements? df free uptime

# Check disk space
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    s.print.log warn "Disk usage at ${DISK_USAGE}%"
    s.print.slack warn "⚠️ Disk usage high: ${DISK_USAGE}%"
fi

# Check memory
MEM_AVAILABLE=$(free -m | awk 'NR==2 {print $7}')
if [ "$MEM_AVAILABLE" -lt 500 ]; then
    s.print.log warn "Low memory: ${MEM_AVAILABLE}MB available"
    s.print.slack warn "⚠️ Low memory: ${MEM_AVAILABLE}MB"
fi

# System uptime
UPTIME=$(uptime -p)
s.print.log info "System status OK - $UPTIME"
```

---

## 🧰 Complete Function Reference

### System Checks

| Function | Description |
|----------|-------------|
| `s.check.os` | Validates OS compatibility (Linux/macOS, Bash 5+) |
| `s.check.root` | Ensures script runs as root |
| `s.check.requirements? cmd1 cmd2` | Verifies required commands exist |
| `s.check.variable? $VAR` | Checks if variable is set |
| `s.check.directory? /path` | Verifies directory exists |
| `s.check.file? /path/file` | Checks if file exists and is not empty |
| `s.check.writable? /path` | Verifies path is writable |

### Logging & Output

| Function | Description |
|----------|-------------|
| `s.print.log LEVEL "message"` | Logs to stdout and syslog (debug/info/notice/warn/error) |
| `s.print.slack LEVEL "message"` | Sends message to Slack with color coding |
| `s.print.human_readable NUM` | Converts bytes to human format (1.2 GB) |
| `s.print.password [LENGTH]` | Generates secure random password (default: 16 chars) |

### Database Operations (MySQL)

| Function | Description |
|----------|-------------|
| `s.db.sanitize? VALUE TYPE` | Validates input (username/database/hostname/grants) |
| `s.db.create.database` | Creates database with validation |
| `s.db.create.user` | Creates user with secure password handling |
| `s.db.set.grants` | Sets user privileges with validation |
| `s.db.set.password` | Updates password (MySQL 8.0+ compatible) |
| `s.db.delete.grants` | Revokes privileges |
| `s.db.delete.user` | Removes user |
| `s.db.delete.database` | Drops database |

### Process Management

| Function | Description |
|----------|-------------|
| `s.process.run CMD ARGS` | Executes command with logging |
| `s.process.single` | Ensures only one instance runs (PID file) |
| `s.process.cleanup` | Cleanup handler (called automatically on exit) |

### Configuration

| Function | Description |
|----------|-------------|
| `s.load.yaml FILE` | Parses YAML to environment variables (`s_config_*`) |
| `s.set.variables` | Initializes default variables |
| `s.set.colors` | Sets up terminal colors |
| `s.set.emojis` | Defines emoji shortcuts |
| `s.set.verbose` | Enables bash debug mode |

### Communications

| Function | Description |
|----------|-------------|
| `s.email.send "SUBJECT"` | Sends email from stdin with sanitization |
| `s.print.slack LEVEL "msg"` | Slack notification with validation |

---

## 🏆 Why Choose smack?

### vs Raw Bash Scripts

| Feature | Raw Bash | smack |
|---------|----------|-------|
| Logging | Manual `echo` statements | Professional logging with levels, colors, syslog |
| Security | Manual validation everywhere | Automatic input validation & sanitization |
| Error Handling | Custom trap handlers | Built-in cleanup & error handling |
| Process Control | Complex PID file logic | Simple `s.process.single` |
| Code Reuse | Copy-paste boilerplate | Import once, use everywhere |
| Learning Curve | Steep (bash gotchas) | Gentle (sensible defaults) |
| Maintenance | High (scattered code) | Low (centralized functions) |

### vs Other Bash Frameworks

- **bashful**: smack is lighter and more focused on practical tasks
- **bash-oo-framework**: smack doesn't try to make bash OOP, stays idiomatic
- **bash-it**: smack is for scripting, not interactive shell customization
- **bats**: smack complements bats (use both!)

### Key Differentiators

✅ **Security Hardened**: Comprehensive SQL injection prevention, password security  
✅ **Production Ready**: 100% shellcheck compliant, zero warnings  
✅ **Zero Dependencies**: Pure bash, works on any Unix-like system  
✅ **Battle Tested**: Used in production environments  
✅ **Well Documented**: Clear examples for every function  
✅ **Active Development**: Regular updates and improvements  

---

## 📊 Code Quality

**smack maintains the highest standards:**

- ✅ **100% Shellcheck Compliant** - Zero errors, zero warnings
- ✅ **Security Audited** - See [SECURITY_FIXES.md](SECURITY_FIXES.md)
- ✅ **Input Validation** - All user inputs are validated and sanitized
- ✅ **Proper Quoting** - Prevents word splitting and globbing issues
- ✅ **Error Handling** - Comprehensive error checking throughout
- ✅ **Documented** - Every function has clear documentation

See [SHELLCHECK_FIXES.md](SHELLCHECK_FIXES.md) for details on the 200+ improvements made.

---

## 🛠️ Advanced Usage

### Custom Configuration

```bash
#!/usr/bin/env smack

# Override defaults
s_config_debug="no"                    # Disable debug output
s_config_syslog_facility="local5"     # Change syslog facility

# Your script logic
```

### Extending smack

```bash
# Create your own functions
function my.custom.function() {
    s.print.log info "My custom logic"
    # Your code here
}

# Use smack functions inside
my.custom.function
```

### Integration with Existing Scripts

```bash
#!/bin/bash

# Source smack manually in existing scripts
source /usr/local/bin/smack

s.print.log info "Now using smack features!"
```

---

## 🔐 Security

smack takes security seriously. All recent security enhancements:

- ✅ **Password Security**: Uses `MYSQL_PWD` environment variable (not visible in `ps`)
- ✅ **SQL Injection Prevention**: Input validation for all database operations  
- ✅ **YAML Injection Prevention**: Safe parsing with validation
- ✅ **Command Injection Prevention**: Email and input sanitization
- ✅ **MySQL 8.0+ Compatible**: Uses modern `ALTER USER` syntax
- ✅ **Webhook Validation**: Slack URLs are validated before use
- ✅ **Timeout Protection**: Network operations have timeouts

See full security audit: [SECURITY_FIXES.md](SECURITY_FIXES.md)

---

## 🤝 Contributing

Contributions are welcome! Please:

1. **Run shellcheck**: All code must pass `shellcheck` with zero warnings
2. **Validate inputs**: Always validate user inputs
3. **Use proper quoting**: Prevent word splitting and globbing
4. **Add tests**: Include examples demonstrating your feature
5. **Document security**: Explain security considerations in comments
6. **Follow conventions**: Use the `s.namespace.function` naming pattern

```bash
# Before submitting:
make build
shellcheck functions/*.sksh boot.sksh examples/scripts/*.sksh
```

---

## 📄 License

MIT © [trentas](https://github.com/trentas)

---

## 🙏 Acknowledgments

Built with ❤️ by developers who got tired of writing the same bash boilerplate.

Special thanks to:
- The shellcheck project for making bash code safer
- Everyone who contributed security fixes
- All the production environments running smack

---

**Ready to smack your bash scripts into shape? [Get started now!](#-quick-start)** 🎯

```bash
git clone https://github.com/trentas/smack.git && cd smack && make install
```
