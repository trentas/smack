# s.db.check.user? db_type host user password
# Checks if db client exists and can connect to db server
# fatal error
function s.db.check.user?() {

}

# s.db.check.database? db_type host user password db_name
# Checks if a database exists
# returns error if it doesn't exists
function s.db.check.database?() {

}

# s.db.create.user db_type host root_password user password
# Creates a user with a password in db server
function s.db.create.user() {

}

# s.db.create.database db_type host root_password db_name
# Creates a new database 
function s.db.create.database() {

}

# s.db.set.grants db_type host root_password user grant1...grantN