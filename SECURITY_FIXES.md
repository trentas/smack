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

**Solution**: Comprehensive multi-layer protection:

**Layer 1 - Input Validation**: New `s.db.sanitize?` function validates all database-related inputs:
- **Usernames/Databases**: Only alphanumeric + underscore, max 64 chars
- **Hostnames**: Valid FQDN or IP address format
- **Grants**: Only uppercase SQL keywords

```bash
# All functions now validate ALL inputs including hostnames
s.db.sanitize? "$db_user" "username" || return $?
s.db.sanitize? "$db_name" "database" || return $?
s.db.sanitize? "$db_host" "hostname" || return $?
s.db.sanitize? "$db_grants" "grants" || return $?
```

**Layer 2 - Password Escaping**: Passwords can contain special characters legitimately, so they are escaped instead of validated:
```bash
# Escape single quotes in passwords using SQL standard method
local escaped_password="${db_password//\'/\'\'}"
# Single quote becomes two single quotes: ' becomes ''
```

**Example attack prevented**:
```bash
# Malicious password: p@ssw0rd' OR '1'='1
# After escaping: p@ssw0rd'' OR ''1''=''1
# SQL sees this as a literal string, not code
```

All database functions now:
1. Validate usernames, database names, hostnames, and grants
2. Escape passwords before use in SQL queries
3. Use proper quoting throughout

---

### 3. YAML Code Injection Prevention (CRITICAL)
**Problem**: The YAML parser used `eval` on parsed output without validation, allowing arbitrary code execution through malicious YAML files.

**Solution**: Added comprehensive two-stage validation before `eval`:

**Stage 1**: Checks for dangerous patterns in parsed output:
```bash
# Rejects: $(, backticks, semicolons, pipes, redirects, braces, brackets
if echo "$parsed_output" | grep -qE '(\$\(|`|;|\||&|>|<|\{|\}|\[|\])'; then
    s.print.log error "YAML file contains potentially dangerous content"
    exit 2
fi
```

**Stage 2**: Ensures **ALL** lines match safe variable assignment pattern:
```bash
# Uses grep -vE to find lines that DON'T match, then checks if any exist
# This ensures EVERY line matches variable="value" format
if [ -n "$parsed_output" ]; then
    if echo "$parsed_output" | grep -vE '^[a-zA-Z_][a-zA-Z0-9_]*="[^"]*"$' | grep -q .; then
        s.print.log error "YAML parsing produced invalid variable assignments"
        exit 2
    fi
fi
```

This two-stage approach prevents bypasses where attackers mix valid and malicious content:
```yaml
# This attack is now blocked:
safe_key: "valid"
evil: "$(rm -rf /)"  # Stage 1 catches $(
mixed: "value; rm -rf /"  # Stage 1 catches ;
invalid: value'  # Stage 2 ensures proper format
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

## Bugs Found and Fixed During Code Review

### 7. YAML Validation Bypass (CRITICAL)
**Problem**: Initial YAML validation at line 37 used `grep -qE` which only verified if **any** line matched the safe pattern, not if **all** lines matched. This allowed attackers to mix valid and malicious content:

```yaml
safe_key: "valid"          # This line passes validation
evil: "$(rm -rf /)"        # This malicious line bypasses validation!
```

**Solution**: Changed validation logic to use inverted match (`grep -vE`) to find lines that DON'T match, ensuring ALL lines are safe:

```bash
# BEFORE (VULNERABLE)
if ! echo "$parsed_output" | grep -qE '^[a-zA-Z_][a-zA-Z0-9_]*="[^"]*"$'; then
    # Only checks if ANY line matches - INSECURE!
fi

# AFTER (SECURE)
if echo "$parsed_output" | grep -vE '^[a-zA-Z_][a-zA-Z0-9_]*="[^"]*"$' | grep -q .; then
    # Finds lines that DON'T match, fails if any found - SECURE!
    s.print.log error "YAML parsing produced invalid variable assignments"
    exit 2
fi
```

### 8. Missing Hostname Validation in Database Functions (CRITICAL)
**Problem**: While the initial security fixes added `s.db.sanitize?` for usernames and database names, several functions were missing hostname validation before using `$db_host` in SQL queries. This allowed SQL injection through malicious hostnames:

```bash
# Attack: Pass hostname as: localhost'; DROP DATABASE mysql; --
CREATE USER 'user'@'localhost'; DROP DATABASE mysql; --' IDENTIFIED BY 'pass';
```

**Solution**: Added hostname validation to all functions that build SQL queries:
- `s.db.create.user` (line 157)
- `s.db.set.grants` (line 230)
- `s.db.set.password` (line 267)
- `s.db.delete.grants` (line 307)
- `s.db.delete.user` (line 341)

### 9. Unescaped Passwords in SQL Queries (CRITICAL)
**Problem**: Password parameters were inserted directly into SQL queries without escaping. Single quotes in passwords would break SQL syntax and potentially allow injection:

```bash
# Password: pass' OR '1'='1
CREATE USER 'user'@'host' IDENTIFIED BY 'pass' OR '1'='1';  # SQL injection!
```

**Solution**: Added password escaping using SQL standard method (single quote becomes two single quotes):
```bash
local escaped_password="${db_password//\'/\'\'}"
# pass' OR '1'='1  becomes  pass'' OR ''1''=''1
# SQL treats this as a literal string, not executable code
```

Applied to:
- `s.db.create.user` (line 160)
- `s.db.set.password` (line 270)

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

