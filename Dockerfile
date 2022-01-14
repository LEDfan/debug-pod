FROM mendhak/http-https-echo:18 AS builder

FROM ubuntu:focal

ENV DOCKER_CHANNEL=stable \
    DOCKER_VERSION=20.10.11 \
    DEBUG=false

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        curl  less dnsutils netcat tcpdump wget traceroute mtr rclone mariadb-client vim pv jq iputils-ping \
        ncdu rsync postgresql-client redis-tools git tmux nodejs tree iptables supervisor iproute2 telnet python3 python3-pip \
        socat psmisc groff && \
    pip3 install plumbum --upgrade --user && \
    pip3 install awscli --upgrade --user && \
    pip3 install git-remote-codecommit --upgrade --user && \
    rm -rf /var/lib/apt/lists/* && \
    curl -o /usr/local/bin/kubectl -L https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    curl -o /usr/local/bin/calicoctl -L  https://github.com/projectcalico/calicoctl/releases/download/v3.16.5/calicoctl && \
    chmod +x /usr/local/bin/calicoctl && \
    curl -o /usr/local/bin/cloudsend.sh -L https://raw.githubusercontent.com/tavinus/cloudsend.sh/master/cloudsend.sh && \
    chmod +x /usr/local/bin/cloudsend.sh && \
    curl -o - -L https://nexus.openanalytics.eu/repository/releases/eu/openanalytics/rdepot/rdepot-cli/1.4.2/rdepot.gz | gunzip > /usr/local/bin/rdepot && \
    chmod +x /usr/local/bin/rdepot && \
    curl -o /usr/local/bin/stern -L https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64  && \
    chmod +x /usr/local/bin/stern

# Docker installation
RUN set -eux; \
	\
	arch="$(uname --m)"; \
	case "$arch" in \
        # amd64
		x86_64) dockerArch='x86_64' ;; \
        # arm32v6
		armhf) dockerArch='armel' ;; \
        # arm32v7
		armv7) dockerArch='armhf' ;; \
        # arm64v8
		aarch64) dockerArch='aarch64' ;; \
		*) echo >&2 "error: unsupported architecture ($arch)"; exit 1 ;;\
	esac; \
	\
	if ! curl -o docker.tgz -L "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${dockerArch}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
	dockerd --version; \
	docker --version

COPY modprobe /usr/local/bin/
COPY supervisor/ /etc/supervisor/conf.d/

RUN chmod +x /usr/local/bin/modprobe

# Webserver installation
COPY --from=builder /app /app

ENV HTTP_PORT=8080 HTTPS_PORT=8443
ENV PATH="/root/.local/bin:${PATH}"

EXPOSE $HTTP_PORT
EXPOSE $HTTPS_PORT

WORKDIR /

CMD ["/usr/bin/supervisord", "-n"]
