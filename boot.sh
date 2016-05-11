#
# smack my bash up bootstrap
#

function s._run() {
	test -z "$@" && return
	source "$@"
}

# Array with current database compatibility
declare -a db_types=(mysql)

s_sourced_script=$_
s_args=($*)

s.check.os?
s.set.variables
s.set.colors
mkdir -p $s_tmpdir

trap s.process.cleanup 0 1 2 9 11 15

s._run "$@"

