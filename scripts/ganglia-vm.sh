#!/usr/bin/env bash
sudo su
set -x

echo "Reading config...." >&2
source /vagrant/setup.rc

export DEBIAN_FRONTEND=noninteractive

export NODE=ganglia-vm
export NODE1=192.168.82.11

bash /vagrant/scripts/ganglia-web.sh