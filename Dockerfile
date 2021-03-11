FROM mendhak/http-https-echo:18 AS builder

FROM ubuntu:focal

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install  --no-install-recommends -y curl less dnsutils netcat tcpdump wget traceroute mtr rclone mariadb-client vim pv jq iputils-ping ncdu rsync postgresql-client git tmux awscli nodejs tree && \
    rm -rf /var/lib/apt/lists/* && \
    curl -o /usr/local/sbin/kubectl -OL https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
    chmod +x /usr/local/sbin/kubectl && \
    curl -o /usr/local/bin/calicoctl -OL  https://github.com/projectcalico/calicoctl/releases/download/v3.16.5/calicoctl && \
    chmod +x /usr/local/bin/calicoctl && \
    curl -o /usr/local/bin/cloudsend.sh -OL https://raw.githubusercontent.com/tavinus/cloudsend.sh/master/cloudsend.sh && \
    chmod +x /usr/local/bin/cloudsend.sh

COPY --from=builder /app /app
ADD start_server.sh /start_server.sh

ENV HTTP_PORT=8080 HTTPS_PORT=8443

EXPOSE $HTTP_PORT
EXPOSE $HTTPS_PORT

WORKDIR /

CMD ["/start_server.sh"]

