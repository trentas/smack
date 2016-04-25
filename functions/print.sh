# s.print.log syslog_priority "message"
# Choose one syslog priority such as debug, info, notice, warn or error and send to syslog and stdout
# Wrong use of this function causes a fatal error
# Thanks to http://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
function s.print.log() {
	test -z "$*" && return
	s.check.requirements? "logger"
	local msg=($*)
	unset msg[0]
	test -z "${msg[*]}" && return
	case $1 in
	debug)
		local loglevel="DEBUG "
		local color=$s_color_purple
		;;
	info)
		local loglevel="INFO  "
		local color=$s_color_blue
		;;
	notice)
		local loglevel="NOTICE"
		local color=$s_color_green
		;;
	warn)
		local loglevel="WARN  "
		local color=$s_color_tan
		;;
	error)
		local loglevel="ERROR "
		local color=$s_color_red
		;;
	*)
		s.print.log error "Usage: s.print.log [debug|info|notice|warn|error] message..."
		exit 2
		;;
	esac
	if [ "$s_config_debug" = "yes" ]; then
		echo -e "${color}[$(date)] ${loglevel} $s_scriptname:${FUNCNAME[0]:+${FUNCNAME[1]}:${BASH_LINENO[0]}} ${msg[*]}${s_color_reset}"
	elif [ "$1" = "debug" ]; then 
		return 1
	fi
	echo -e "$loglevel $s_scriptname:${FUNCNAME[0]:+${FUNCNAME[1]}:${BASH_LINENO[0]}} ${msg[*]}" | logger -p $s_config_syslog_facility.$1
}

# s.print.human_readable number_in_bytes
# Convert a number to a human readable representation like numfmt
function s.print.human_readable() {
	b=${1:-0}
	d=''
	s=0
	S=(Bytes {K,M,G,T,E,P,Y,Z}B)
	while ((b > 1024)); do
		d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
		b=$((b / 1024))
		let s++
	done
	echo "$b$d${S[$s]}"
}

# s.print.loading1 
# Prints a funny cursor dance
function s.print.loading1() {
	echo -ne "-.."\\r
	sleep 0.15
	echo -ne ".-."\\r
	sleep 0.15
	echo -ne "..-"\\r
	sleep 0.15
	echo -ne ".-."\\r
	sleep 0.15
}

# s.print.loading2 
# Prints a funny cursor dance
function s.print.loading2() {
	echo -ne "-"\\r
	sleep 0.1
	echo -ne "\\\\"\\r
	sleep 0.1
	echo -ne "|"\\r
	sleep 0.1
	echo -ne "/"\\r
	sleep 0.1
}
