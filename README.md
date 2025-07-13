# smack 🧨

A lightweight Bash utility library to make your scripts cleaner, safer, and more readable.

**smack** provides battle-tested helpers for logging, error handling, command checks, and common scripting patterns — so you can focus on the logic, not the boilerplate.

---

## 🚀 Features

- Consistent, colorful logging
- OS and user privilege checks
- Database management helpers
- Slack integration and human-readable output
- Command execution with logging
- YAML parsing into environment variables
- Email sending via SMTP
- Clean process lifecycle handling
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
| `s.db.create.user`          | Creates a new database user                                                |
| `s.db.create.database`      | Creates a new database                                                     |
| `s.db.set.grants`           | Sets privileges for a user on a database                                   |
| `s.db.set.password`         | Updates the password for a database user                                   |
| `s.db.delete.grants`        | Removes privileges from a user                                             |
| `s.db.delete.user`          | Deletes a database user                                                    |
| `s.db.delete.database`      | Deletes a database                                                         |
| `s.email.send`              | Sends an email using configured SMTP                                       |
| `s.load.yaml`               | Parses a YAML file and exports its contents as environment variables       |
| `s.print.log`               | Prints a log message to stdout/stderr based on log level                   |
| `s.print.slack`             | Sends a formatted message to a Slack webhook                               |
| `s.print.human_readable`    | Converts bytes or seconds into a readable format (e.g., 1.2 MB, 3m15s)      |
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

## 🤝 Contributing

Pull requests and issues are welcome!  
Make sure to run `shellcheck` and keep functions portable.

---

## 📄 License

MIT © [trentas](https://github.com/trentas)
