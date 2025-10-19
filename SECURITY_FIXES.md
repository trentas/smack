# Security Fixes Applied to Smack

This document summarizes the critical security improvements made to the smack library.

## Fixed Issues

### 1. Database Password Exposure (CRITICAL)
**Problem**: Database passwords were passed via command-line arguments (`-p$password`), making them visible in process lists, logs, and shell history.

**Solution**: All database functions now use the `MYSQL_PWD` environment variable instead:
```bash
# Before (INSECURE)
mysql -u root -p$password -e "..."

# After (SECURE)
MYSQL_PWD="$password" mysql -u root -e "..."
```

**Affected functions**:
- `s.db.check.user?`
- `s.db.check.database?`
- `s.db.create.user`
- `s.db.create.database`
- `s.db.set.grants`
- `s.db.set.password`
- `s.db.delete.grants`
- `s.db.delete.user`
- `s.db.delete.database`

---

### 2. SQL Injection Prevention (CRITICAL)
**Problem**: User inputs were directly interpolated into SQL queries without validation or escaping.

**Solution**: New `s.db.sanitize?` function validates all database-related inputs:
- **Usernames/Databases**: Only alphanumeric + underscore, max 64 chars
- **Hostnames**: Valid FQDN or IP address format
- **Grants**: Only uppercase SQL keywords

```bash
# Usage
s.db.sanitize? "$db_user" "username" || return $?
s.db.sanitize? "$db_name" "database" || return $?
s.db.sanitize? "$db_host" "hostname" || return $?
s.db.sanitize? "$db_grants" "grants" || return $?
```

All database functions now validate inputs before executing queries.

---

### 3. YAML Code Injection Prevention (HIGH)
**Problem**: The YAML parser used `eval` on parsed output without validation, allowing arbitrary code execution through malicious YAML files.

**Solution**: Added validation before `eval`:
1. Parses YAML into variable assignments
2. Checks for dangerous patterns: `$(`, backticks, semicolons, pipes, etc.
3. Validates that all lines match safe variable assignment pattern: `variable="value"`
4. Only then executes `eval`

```bash
# Rejects malicious content like:
# value: "$(rm -rf /)"
# value: "; cat /etc/passwd"
```

---

### 4. Email Command Injection (HIGH)
**Problem**: Email subject lines were not escaped, allowing command injection through the `mail -s` parameter.

**Solution**: 
1. Added email address format validation
2. Removed/escaped dangerous characters from subject line:
   - Escaped: `$` (dollar signs)
   - Removed: backticks, parentheses, semicolons, pipes, ampersands
3. Added proper quoting around variables

```bash
# Validates email format
if ! echo "$s_config_email_address" | grep -qE '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; then
    # reject invalid email
fi

# Sanitizes subject line before passing to mail command
```

---

### 5. Slack Webhook Security (MEDIUM)
**Problem**: Slack webhook calls had no timeout, error handling, or URL validation.

**Solution**:
1. Validates webhook URL format (must start with `https://hooks.slack.com/`)
2. Added proper JSON escaping (backslashes, quotes)
3. Added curl security options:
   - `--max-time 10`: 10-second timeout
   - `--fail`: Exit with error on HTTP errors
   - `--show-error`: Show error messages
   - Proper error handling with response capture

```bash
# Validates webhook URL
if ! echo "$s_config_slack_url" | grep -qE '^https://hooks\.slack\.com/'; then
    s.print.log error "Invalid Slack webhook URL format"
    return 2
fi

# Sends with timeout and error handling
local response=$(curl --max-time 10 --silent --show-error --fail ...)
```

---

### 6. MySQL 8.0+ Compatibility (MEDIUM)
**Problem**: `s.db.set.password` used deprecated `PASSWORD()` function removed in MySQL 8.0.

**Solution**: Updated to use `ALTER USER ... IDENTIFIED BY` which works in MySQL 5.7+.

```sql
-- Before (deprecated in MySQL 8.0)
SET PASSWORD FOR 'user'@'host' = PASSWORD('pass');

-- After (MySQL 5.7+ compatible)
ALTER USER 'user'@'host' IDENTIFIED BY 'pass';
```

---

## Additional Improvements

### Documentation
- Updated README.md with security features
- Added new Security section explaining protections
- Updated function descriptions to mention validation
- Added contributing guidelines for security

### Function Table Updated
- Added `s.db.sanitize?` to function list
- Updated descriptions to mention security features
- Clarified MySQL 8.0+ compatibility

---

## Testing Recommendations

Before deploying these changes, test:

1. **Database operations** with various input types:
   - Valid usernames/databases with underscores
   - Invalid inputs (special characters, SQL keywords)
   - Long inputs (>64 chars)

2. **YAML parsing** with:
   - Normal YAML files
   - YAML with command substitution attempts
   - YAML with special characters

3. **Email sending** with:
   - Normal subject lines
   - Subject lines containing special characters
   - Invalid email addresses

4. **Slack notifications** with:
   - Valid webhook URLs
   - Invalid webhook URLs
   - Messages containing special characters
   - Network timeout scenarios

---

## Backward Compatibility

All changes maintain backward compatibility:
- Function signatures unchanged
- Return codes consistent
- Behavior same for valid inputs
- Only rejects previously-unsafe inputs

Scripts using smack with valid inputs will continue to work without modification.

---

## Future Recommendations

Consider implementing:
1. Rate limiting for network operations
2. Retry logic with exponential backoff
3. Support for PostgreSQL/other databases
4. Unit tests using bats (Bash Automated Testing System)
5. Integration with secret management tools (vault, etc.)

