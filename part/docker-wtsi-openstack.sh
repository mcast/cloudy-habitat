#! /bin/sh

# From https://gitlab.internal.sanger.ac.uk/CGPaaS/CGPaaS-terraform/tree/develop/docker-swarm#running-on-linux

docker network rm docker_gwbridge || true

SUBNET=192.168.66.0/24
GATEWAY=192.168.66.1
docker network create --subnet=${SUBNET} --gateway ${GATEWAY} -o \
  com.docker.network.bridge.enable_icc=false -o \
  com.docker.network.bridge.name=docker_gwbridge docker_gwbridge -o \
  com.docker.network.bridge.enable_ip_masquerade=true -o \
  com.docker.network.driver.mtu=1380
