#
#

function s.check.requirements?() {
	test -z "$*" && return
	while [ -n "$1" ]; do
		if ! which "$1" &> /dev/null; then
			s.print.log error "$1 not found or permission denied"
			exit 2
		fi
		shift
	done
}

function s.check.variable?() {
	if [ -z "$1" ]; then
		return 2
	else
		return 0
	fi
}

function s.check.os() {
	if [ ! $(uname) = "Linux" -a ! $(uname) = "Darwin" ]; then
		s.print.log error "Operating system $(uname) not supported"
		exit 2
	fi
}

