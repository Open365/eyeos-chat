#!/bin/bash
set -e
set -u

tail -F /opt/ejabberd-16.04/logs/ejabberd.log \
		/opt/ejabberd-16.04/logs/error.log \
		/opt/ejabberd-16.04/logs/crash.log \ &

eyeos-service-ready-notify-cli &

ejabberdctl start   --node ejabberd@localhost \
                    --config-dir /var/service/ejabberd-config/ \
                    --logs /opt/ejabberd-16.04/logs \
                    --spool /opt/ejabberd-16.04/database/ejabberd@localhost