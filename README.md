# Debug-pod

Docker image with various tools useful when debugging inside a Kubernetes clusters.

Thanks to [iptizer](https://github.com/iptizer/swiss) for the idea!

## Included tools

 - Docker in Docker: https://github.com/cruizba/ubuntu-dind (Thanks [@cruizba](http://github.com/cruizba) !)
 - A webserver that outputs information about the incoming request: https://github.com/mendhak/docker-http-https-echo (Thanks [@mendhak](https://github.com/mendhak) !)
 - [RDepot CLI](https://github.com/openanalytics/rdepot-cli/)
 - [cloudsend.sh](https://github.com/tavinus/cloudsend.sh)
 - kubectl
 - calicoctl
 - python3 + pip3 + [plumbum](https://plumbum.readthedocs.io/en/latest/index.html)
 - bunch of standard Linux tools
 - [stern](https://github.com/wercker/stern)


## sshuttle

This container can be used with [sshuttle](https://sshuttle.readthedocs.io/en/stable/) + [kuttle](https://github.com/kayrus/kuttle), in order to get access to the Kubernetes network from your local machine.
This repository contains a patched [kuttle](kuttle) file. The patch simply adds quotes around `$1` on line 4.

1. install sshuttle:

    ```bash
    sudo pacman -S sshuttle
    ```

2. install kuttle:

    ```bash
    install kuttle /usr/local/bin/kuttle
    ```

2. create a debug-pod
3. launch sshuttle, specifying the name of the debug-pod (running in the `default` namespace) and the CIDR of your Kubernetes cluster:

    ```bash
    sshuttle -r debug-pod -e kuttle 10.42.42.0/20
    ```

You can now access the Kubernetes network from your local machine.

### Conditional DNS Forwarding

In addition to forwarding TCP traffic, sshuttle can forward DNS traffic as well. This is very useful for accesing resources in your cluster using the Kubernetes DNS server (e.g. `kubernetes.default.svc`) or when you have a private DNS zone in your cluster (e.g. using AWS Route53).
This can be enabled by simply specifying `--dns` as an option to sshuttle. However, this forwards **all** your DNS traffic through the DNS server of Kubernetes, which is undesirable in most cases.
A solution is to use [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) on your local machine:

1. install dnsmasq

    ```bash
    sudo pacman -S dnsmasq
    ```

2. edit the config file (`/etc/dnsmasq.conf`)

    ```text
    domain-needed
    no-resolv
    no-poll
    # the following line forwards all subdomains of `my-corporation.com` to the DNS server 10.42.42.2
    server=/my-corporation.com/10.42.42.2
    # the following line forwards all other traffic to 9.9.9.9, choose any DNS server you like
    server=9.9.9.9
    ```

3. start and enable dnsmasq:

    ```bash
    sudo systemctl start dnsmasq
    sudo systemctl enable dnsmasq
    ```

4. run sshuttle:

    ```bash
    sshuttle -r debug-pod -e kuttle 10.42.42.0/20 --ns-hosts=10.42.42.2
    ```


This setup resolves sub-domain of `my-corporation.com` through the DNS server at `10.42.42.2`.
All other domains are resolved using `9.9.9.9`.

### Performance

When you need to transfer big files using the tunnel add the [`--no-latency-control`](https://sshuttle.readthedocs.io/en/stable/manpage.html#cmdoption-sshuttle-no-latency-control) option to sshuttle.
With this option enabled, `iperf3` reports around 150Mbps throughput for my situation.

### Forwarding script

The following script can be used for convience:

```bash
#!/usr/bin/env bash

killall sshuttle

function finish {
    kill $(jobs -p) # kill background loops
}

trap finish EXIT

# Cluster 1
while /bin/true; do
    sshuttle -r '--context my-cluster-1 debug-pod' -e kuttle --no-latency-control --ns-hosts=10.42.42.2 10.42.42.0/20
    sleep 1
done &

# Cluster 2
while /bin/true; do
    sshuttle -r '--context my-cluster-2 debug-pod' -e kuttle --no-latency-control --ns-hosts=10.142.42.2 10.142.42.0/20
    sleep 1
done &

wait
```
