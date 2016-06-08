FROM docker-registry.eyeosbcn.com/alpine6-node-base

ENV WHATAMI chat

ENV InstallationDir /var/service/

WORKDIR ${InstallationDir}

COPY . ${InstallationDir}

RUN apk update && \
    /scripts-base/buildDependencies.sh --production --install && \
    wget https://s3-eu-west-1.amazonaws.com/apk-packages/ejabberd-16.04-r0.apk && \
    apk add --no-cache --allow-untrusted ejabberd-16.04-r0.apk && \
    npm install -g --verbose eyeos-service-ready-notify-cli && \
    npm install --verbose --production && \
    npm cache clean && \
    /scripts-base/buildDependencies.sh --production --purgue && \
    rm -fr /etc/ssl /var/cache/apk/* /tmp/* ejabberd-16.04-r0.apk

CMD eyeos-run-server --serf ${InstallationDir}/start.sh
