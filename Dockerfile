FROM docker-registry.eyeosbcn.com/eyeos-fedora21-node-base

WORKDIR ${InstallationDir}

ENV WHATAMI chat

RUN yum install wget -y \
    && wget -O ejabberd.rpm https://www.process-one.net/downloads/downloads-action.php?file=/ejabberd/16.04/ejabberd-16.04-0.x86_64.rpm \
    && yum localinstall ejabberd.rpm -y \
    && yum clean all \
    && rm ejabberd.rpm \
    && mkdir -p /var/service

ENV PATH /opt/ejabberd-16.04/bin:${PATH}

COPY . ${InstallationDir}

RUN npm install --verbose && npm install -g eyeos-service-ready-notify-cli && \
    npm cache clean

CMD eyeos-run-server --serf ${InstallationDir}/start.sh
