#!/usr/bin/env bash
### BEGIN INIT INFO
# Provides:          loraserver
# Required-Start:    $all
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: LoRaWAN network-server
### END INIT INFO


# set variables for exporting (needed for DEFAULT_FILE)
set -a

NAME=loraserver
DESC="LoRa Server"
DAEMON_USER=loraserver
DAEMON_GROUP=loraserver
DAEMON=/usr/bin/$NAME
PID_FILE=/var/run/$NAME.pid
DEFAULT_FILE=/etc/default/$NAME


# check root
if [ "$UID" != "0" ]; then
    echo "You must be root to run this script"
    exit 1
fi

# check daemon
if [ ! -x $DAEMON ]; then
    echo "Executable $DAEMON does not exist"
    exit 5
fi

# load functions and settings
. /lib/lsb/init-functions

if [ -r /etc/default/rcS ]; then
	. /etc/default/rcS
fi

if [ -f "$DEFAULT_FILE" ]; then
	. "$DEFAULT_FILE"
fi

function do_start {
	start-stop-daemon --start --background --chuid "$DAEMON_USER:$DAEMON_GROUP" --make-pidfile --pidfile "$PID_FILE" --startas /bin/bash -- -c "exec $DAEMON > /var/log/loraserver/loraserver.log 2>&1"
}

function do_stop {
	start-stop-daemon --stop --retry=TERM/30/KILL/5 --pidfile "$PID_FILE" --name "$NAME"
	retval="$?"
	sleep 1
	return "$retval"
}

case "$1" in
	start)
		log_daemon_msg "Starting $DESC"
		do_start
		case "$?" in
			0|1) log_end_msg 0 ;;
			2) log_end_msg 1 ;;
		esac
		;;
	stop)
		log_daemon_msg "Stopping $DESC"
		do_stop
		case "$?" in
			0|1) log_end_msg 0 ;;
			2) log_end_msg 1 ;;
		esac
		;;
	restart)
		log_daemon_msg "Restarting $DESC"
		do_stop
		case "$?" in
			0|1)
				do_start
				case "$?" in
					0) log_end_msg 0 ;;
					1) log_end_msg 1 ;;
					*) log_end_msg 1 ;;
				esac
				;;
			*)
				log_end_msg 1
				;;
		esac
		;;
	status)
		status_of_proc -p "$PID_FILE" "$DAEMON" "$NAME" && exit 0 || exit $?
		;;
	*)
		echo "Usage: $NAME {start|stop|restart|status}" >&2
		exit 3
		;;
esac
