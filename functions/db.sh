# s.db.check.user? db_type db_host db_user db_password
# Checks if db client exists and can connect to db server
# fatal error
function s.db.check.user?() {

}

# s.db.check.database? db_type db_host db_user db_password db_name
# Checks if a database exists
# returns error if it doesn't exists
function s.db.check.database?() {

}

# s.db.create.user db_type db_host db_root_password db_user db_password
# Creates a user with a password in db server
function s.db.create.user() {

}

# s.db.create.database db_type db_host db_root_password db_name
# Creates a new database 
function s.db.create.database() {

}

# s.db.set.grants db_type db_host db_root_password db_name db_user grant1...grantN
# Set permissions to a specific user access the database
function s.db.set.grants() {

}

# s.db.set.password db_type db_host db_root_password db_user db_password
# Set new password to a specific user
function s.db.set.password() {

}
