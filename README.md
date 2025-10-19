# smack 🧨

A lightweight Bash utility library to make your scripts cleaner, safer, and more readable.

**smack** provides battle-tested helpers for logging, error handling, command checks, and common scripting patterns — so you can focus on the logic, not the boilerplate.

---

## 🚀 Features

- Consistent, colorful logging with syslog integration
- OS and user privilege checks
- Database management helpers with SQL injection prevention
- Slack integration with timeout and error handling
- Command execution with logging
- YAML parsing into environment variables with injection prevention
- Email sending via SMTP with input sanitization
- Clean process lifecycle handling
- Secure password handling (no passwords in process list)
- Input validation and sanitization throughout
- Minimalist, zero-dependency, and portable (pure Bash)

---

## 📦 Installation

Run:

```bash
make install
```

This will generate the final script and copy it to `/usr/local/bin/smack`.

To uninstall:

```bash
make uninstall
```

---

## 🧪 Usage

```bash
#!/usr/bin/env smack

s.check.os
s.print.log "Starting process..."
s.process.run "echo Hello"
```

---

## 🧰 Available Functions

| Function                     | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `s.check.os`                | Checks the current operating system and architecture                       |
| `s.check.root`              | Ensures the script is running as root                                      |
| `s.db.sanitize?`            | Validates and sanitizes database inputs to prevent SQL injection           |
| `s.db.create.user`          | Creates a new database user (with input validation)                        |
| `s.db.create.database`      | Creates a new database (with input validation)                             |
| `s.db.set.grants`           | Sets privileges for a user on a database (with input validation)           |
| `s.db.set.password`         | Updates the password for a database user (MySQL 8.0+ compatible)           |
| `s.db.delete.grants`        | Removes privileges from a user (with input validation)                     |
| `s.db.delete.user`          | Deletes a database user (with input validation)                            |
| `s.db.delete.database`      | Deletes a database (with input validation)                                 |
| `s.email.send`              | Sends an email using configured SMTP (with input sanitization)             |
| `s.load.yaml`               | Parses a YAML file and exports its contents as environment variables       |
| `s.print.log`               | Prints a log message to stdout/stderr based on log level                   |
| `s.print.slack`             | Sends a formatted message to a Slack webhook (with timeout and validation) |
| `s.print.human_readable`    | Converts bytes or seconds into a readable format (e.g., 1.2 MB, 3m15s)     |
| `s.print.password`          | Generates and prints a secure random password                              |
| `s.process.run`             | Executes a command and logs its output                                     |
| `s.process.single`          | Ensures that a process runs only once at a time                            |
| `s.process.cleanup`         | Handles cleanup logic at the end of a script or on exit                    |
| `s.set.colors`              | Sets up terminal colors for use in output                                  |
| `s.set.emojis`              | Defines emoji shortcuts for user-friendly logs                             |
| `s.set.variables`           | Loads default/global environment variables                                 |
| `s.set.verbose`             | Enables or disables verbose mode                                           |

---

## 📂 Examples

You can create a `demo.sksh` like this:

```bash
#!/usr/bin/env smack

s.check.os
s.print.log "Environment is OK"
s.print.password
```

---

## 🔒 Security

**smack** takes security seriously:

- **Database operations**: All database functions use `MYSQL_PWD` environment variable to prevent password exposure in process lists
- **SQL injection prevention**: New `s.db.sanitize?` function validates all database-related inputs (usernames, database names, hostnames, grants)
- **YAML parsing**: Input validation prevents code injection through malicious YAML files
- **Email**: Subject lines are sanitized to prevent command injection
- **Slack**: Webhook URLs are validated, timeouts prevent hanging, and proper JSON escaping is applied
- **MySQL 8.0+ compatible**: Uses `ALTER USER` instead of deprecated `PASSWORD()` function

## 🤝 Contributing

Pull requests and issues are welcome!  
Make sure to run `shellcheck` and keep functions portable.

When contributing:
- Validate all user inputs
- Use proper quoting to prevent word splitting
- Avoid exposing sensitive data in process lists or logs
- Add comments explaining security considerations

---

## 📄 License

MIT © [trentas](https://github.com/trentas)
