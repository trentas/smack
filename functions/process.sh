# s.process.run arg1...argN
# Just runs a script
s.process.run() {
	test -z "$*" && return
	source $@
}

# s.process.single
# Creates PID files in the filesystem and avoids the same script to run simultaneously
s.process.single() {
	local current_pid=$$
	local file_pid=$s_rundir/${s_scriptname}.pid
	s.print.log debug "Current PID is $current_pid"
	if [ -s $file_pid ]; then
		s.print.log debug "File PID is $file_pid, validating"
		local pid_running=$(ps aux | awk '{ print $2 }' | grep -F $(cat $file_pid))
		if [ "$current_pid" = "$(cat $file_pid)" ]; then
			s.print.log debug "how did you come up here?"
			exit 0
		elif [ ! "$pid_running" = "" ]; then
			s.print.log notice "Process $s_scriptname is already running with PID $pid_running"
			exit 0
		else
			s.print.log error "Stalled PID File, overwriting"
		fi
	else
		s.print.log debug "PID file not found"
	fi
	if [ -w $s_rundir ]; then
		s.print.log info "Creating PID file"
		echo $current_pid > $file_pid
	else
		s.print.log error "Directory $s_rundir not writeable, cant write PID file"
		exit 2
	fi
}
