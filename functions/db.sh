# Array with current database compatibility
declare -a db_types=(mysql)

# s.db.list.compat? db_type
# Returns true if compatible with db_type, no args lists returns a list
function s.db.list.compat?() {
	local db_type
	if [ -z $1 ]; then
		for db_type in ${db_types[@]}
		do
			echo $db_type
		done
		s.print.log debug "List of compatible databases: ${db_types[@]}"
	else
		for db_type in ${db_types[@]}
		do
			if [ "$db_type" == "$1" ]; then
				s.print.log debug "Database $db_type is compatible"
				return 0
			fi
		done
		s.print.log debug "Database $db_type is not compatible"
		return 2
	fi
}

# s.db.check.user? db_type db_host db_user db_password
# Checks if db client exists and can connect to db server
# fatal error
function s.db.check.user?() {
	test -z "$*" && return
	local db_type=$1
	local db_host=$2
	local db_user=$3
	local db_password=$4
	local db_query="\"USE mysql\""
	s.db.list.compat? $db_type || return $?
	case $db_type in
		mysql)
			if [ "$s_os" = "Linux" ]; then
				s.check.requirements? "mysql"
				s_db_client=mysql
			elif [ "$s_os" = "Darwin" ]; then
				s.check.requirements? "mysql5"
				s_db_client=mysql5
			else
				s.check.os?
			fi
			#blabla="$s_db_client -h $db_host -u $db_user -p$db_password --skip-column-names -e $db_query"
			#eval $blabla
			#s.process.run $blabla
			s.process.run $s_db_client -h $db_host \
						-u $db_user \
						-p$db_password \
						--skip-column-names \
						-e $db_query
			if [ $? -eq 0 ]; then
				s.print.log info "Valid database user: $db_user"
			else
				s.print.log error "Can't connect with Mysql server with user $db_user"
			fi		
			;;
	esac
}

# s.db.check.database? db_type db_host db_user db_password db_name
# Checks if a database exists
# returns error if it doesn't exists
function s.db.check.database?() {
	test -z "$*" && return
	local db_type=$1
	local db_host=$2
	local db_user=$3
	local db_password=$4
	local db_name=$5
	s.db.list.compat? $db_type && return $?
	s.db.check.user? $db_type $db_host $db_user $db_password && return $?
	case $db_type in
		mysql)
			s.process.run mysql -h $db_host \
						-u $db_user \
						-p$db_password \
						--skip-column-names \
						-e USE\ $db_name
			;;
	esac
}

# s.db.create.user db_type db_host db_root_password db_user db_password
# Creates a user with a password in db server
function s.db.create.user() {
	test -z "$*" && return
}

# s.db.create.database db_type db_host db_root_password db_name
# Creates a new database 
function s.db.create.database() {
	test -z "$*" && return
}

# s.db.set.grants db_type db_host db_root_password db_name db_user grant1...grantN
# Set permissions to a specific user access the database
function s.db.set.grants() {
	test -z "$*" && return
}

# s.db.set.password db_type db_host db_root_password db_user db_password
# Set new password to a specific user
function s.db.set.password() {
	test -z "$*" && return
}
