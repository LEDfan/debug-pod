FROM ubuntu:focal

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl less dnsutils netcat tcpdump wget traceroute mtr rclone mariadb-client vim pv jq iputils-ping ncdu rsync postgresql-client git tmux awscli && \
    rm -rf /var/lib/apt/lists/*

# kubectl
RUN curl -o /usr/local/sbin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && chmod +x /usr/local/sbin/kubectl

# calicoctl
RUN curl -o /usr/local/bin/calicoctl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.16.5/calicoctl && chmod +x /usr/local/bin/calicoctl

ENTRYPOINT ["/bin/bash","-c"]
CMD ["bash"]

