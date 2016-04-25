#
# smack my bash up bootstrap
#

function s._run() {
	test -z "$*" && return
	source $@
}

s_sourced_script=$_
s_args=($*)

s.check.os?
s.set.variables
s.set.colors

s._run "$@"

