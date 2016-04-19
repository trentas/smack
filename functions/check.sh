# s.check.requirements? arg1...argN
# check if one or a set of executable files exist
# fatal error
function s.check.requirements?() {
	test -z "$*" && return
	while [ -n "$1" ]; do
		if ! which "$1" &> /dev/null; then
			s.print.log error "Fatal: $1 not found or permission denied"
			exit 2
		fi
		shift
	done
}

# s.check.variable? arg1
# check if one variable exists
# returns an exit code 2 if not found
# bash is so beautifully crazy that true is zero
function s.check.variable?() {
	if [ -z "$1" ]; then
		return 2
	else
		return 0
	fi
}

# s.check.os? 
# check if this script is running from a mac or linux box. (no windows 10 support yet!)
# fatal error
function s.check.os?() {
	if [ ! $(uname) = "Linux" -a ! $(uname) = "Darwin" ]; then
		s.print.log error "Operating system $(uname) not supported"
		exit 2
	fi
}

