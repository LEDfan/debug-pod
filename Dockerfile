FROM mendhak/http-https-echo:18 AS builder

FROM ubuntu:focal

ENV DOCKER_CHANNEL=stable \
    DOCKER_VERSION=19.03.11 \
    DOCKER_COMPOSE_VERSION=1.26.0 \
    DEBUG=fals

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y curl less dnsutils netcat tcpdump wget traceroute mtr rclone mariadb-client vim pv jq iputils-ping ncdu rsync postgresql-client git tmux awscli nodejs tree iptables supervisor && \
    rm -rf /var/lib/apt/lists/* && \
    curl -o /usr/local/sbin/kubectl -OL https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/sbin/kubectl && \
    curl -o /usr/local/bin/calicoctl -OL  https://github.com/projectcalico/calicoctl/releases/download/v3.16.5/calicoctl && \
    chmod +x /usr/local/bin/calicoctl && \
    curl -o /usr/local/bin/cloudsend.sh -OL https://raw.githubusercontent.com/tavinus/cloudsend.sh/master/cloudsend.sh && \
    chmod +x /usr/local/bin/cloudsend.sh

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
	if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${dockerArch}/docker-${DOCKER_VERSION}.tgz"; then \
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

COPY modprobe startup.sh /usr/local/bin/
COPY supervisor/ /etc/supervisor/conf.d/
COPY logger.sh /opt/bash-utils/logger.sh

RUN chmod +x /usr/local/bin/startup.sh /usr/local/bin/modprobe

# Webserver installation
COPY --from=builder /app /app

ENV HTTP_PORT=8080 HTTPS_PORT=8443

EXPOSE $HTTP_PORT
EXPOSE $HTTPS_PORT

WORKDIR /

CMD ["startup.sh"]
