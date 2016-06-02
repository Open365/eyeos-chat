#!/bin/bash
set -e
set -u

tail -F /var/log/ejabberd/ejabberd.log \
		/var/log/ejabberd/error.log \
		/var/log/ejabberd/crash.log \ &

eyeos-service-ready-notify-cli &

ejabberdctl start   --node ejabberd@localhost \
                    --config-dir /var/service/ejabberd-config/ \
                    --logs /var/log/ejabberd
