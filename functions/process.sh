# s.process.run arg1...argN
# Just runs a script
function s.process.run() {
	test -z "$@" && return
	s.print.log debug "running: $@"
	$@ > $s_stdout 2> $s_stderr
	s.print.log debug "stdout: $(cat $s_stdout)"
	s.print.log debug "stderr: $(cat $s_stderr)"	
}

# s.process.single
# Creates PID files in the filesystem and avoids the same script to run simultaneously
function s.process.single() {
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

# s.process.cleanup
# clean the mess and exit
function s.process.cleanup() {
	exitcode=$?
	local file_pid=$s_rundir/${s_scriptname}.pid
	rm -f $file_pid $s_tmpdir
	s.print.log debug "Exiting with code: $exitcode"
	exit $exitcode
}

