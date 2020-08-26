ARG UBI_IMAGE=registry.access.redhat.com/ubi7/ubi-minimal:latest
ARG GO_IMAGE=rancher/build-base:v1.14.2

FROM ${UBI_IMAGE} as ubi

FROM ${GO_IMAGE} as builder
ARG TAG="" 
ARG K3S_ROOT_VERSION=v0.6.0-rc3
RUN apt update     && \ 
    apt upgrade -y && \ 
    apt install -y ca-certificates git bash rsync

RUN mkdir -p /tmp/xtables && \
    curl -L https://github.com/rancher/k3s-root/releases/download/${K3S_ROOT_VERSION}/k3s-root-xtables-amd64.tar -o /tmp/xtables/k3s-root-xtables.tar && \
    tar -C /tmp/xtables -xvf /tmp/xtables/k3s-root-xtables.tar

RUN git clone --depth=1 https://github.com/kubernetes/kubernetes.git
RUN cd /go/kubernetes                  && \
    git fetch --all --tags --prune     && \
    git checkout tags/${TAG} -b ${TAG} && \
    make kube-proxy

FROM ubi
RUN microdnf update -y     && \
    microdnf install -y which \
    conntrack-tools        && \ 
    rm -rf /var/cache/yum

COPY --from=builder /tmp/xtables/bin/* /usr/sbin/

COPY --from=builder /go/kubernetes/_output/bin/kube-proxy /usr/local/bin

