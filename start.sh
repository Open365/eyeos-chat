#!/bin/sh
set -e
set -u

finish_everything() {
	echo "Got signal to finish"
	ejabberdctl stop
	# wait while beam.smp (main ejabberd process) is still alive.
	# when it is zombie, or the process doesn't appear anymore we can
	# finally destroy the container (by killing tail and ending the `wait`)
	jabber_status="$(ps -o comm,stat | awk '$1 == "beam.smp" { print substr($2, 0, 1) }')"
	while [ "$jabber_status" = R -o "$jabber_status" = S ]
	do
		sleep 1
		jabber_status="$(ps -o comm,stat | awk '$1 == "beam.smp" { print $2 }')"
	done
	echo "Main ejabberd process has ended. We can now destroy the container"
	kill $TAILPID
}

trap finish_everything SIGTERM SIGINT

tail -F /var/log/ejabberd/ejabberd.log \
		/var/log/ejabberd/error.log \
		/var/log/ejabberd/crash.log &
TAILPID=$!

eyeos-service-ready-notify-cli &

ejabberdctl start   --node ejabberd@localhost \
                    --config-dir /var/service/ejabberd-config/ \
                    --logs /var/log/ejabberd

wait
