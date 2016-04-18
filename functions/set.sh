#
#

function s.set.colors() {
	s.check.requirements? "tput"
	s_color_bold=$(tput bold)
	s_color_underline=$(tput sgr 0 1)
	s_color_purple=$(tput setaf 171)
	s_color_red=$(tput setaf 1)
	s_color_green=$(tput setaf 76)
	s_color_tan=$(tput setaf 3)
	s_color_blue=$(tput setaf 38)
	s_color_reset=$(tput sgr0)
}

function s.set.variables() {
	s.check.requirements? "basename"
	s_scriptname=$(basename $s_sourced_script)
	s_rundir=/var/run
	eval $(s.load.yaml ${s_args[1]})
	if ! s.check.variable? "$s_config_debug"; then
		s_config_debug="yes"
	fi
	if ! s.check.variable? "$s_config_syslog_facility"; then
		s_config_syslog_facility="local5"
	fi
}

function s.set.verbose() {
	set -x
}


