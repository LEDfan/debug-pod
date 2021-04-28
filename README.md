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


