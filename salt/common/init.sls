

{%- from "kubernetes/map.jinja" import common with context -%}
{%- from "kubernetes/map.jinja" import master with context -%}

/usr/bin/kubectl:
  file.managed:
    - source: https://storage.googleapis.com/kubernetes-release/release/{{ common.version }}/bin/linux/amd64/kubectl
    - skip_verify: true
    - show_changes: False
    - group: root
    - mode: 755

azure-cli:
  pkgrepo.managed:
    - name: deb https://packages.microsoft.com/repos/azure-cli/ bionic main
    - dist: bionic
    - file: /etc/apt/sources.list.d/azure-cli.list
    - gpgcheck: 1
    - key_url: https://packages.microsoft.com/keys/microsoft.asc
  pkg.latest:
    - name: azure-cli
    - refresh: true

ceph-common:
  pkg.latest:
    - refresh: true

httpie:
  pkg.latest:
    - refresh: true

jq:
  pkg.latest:
    - refresh: true

conntrack:
  pkg.latest:
    - refresh: true

bridge-utils:
  pkg.latest:
    - refresh: true

socat:
  pkg.latest:
    - refresh: true

wget:
  pkg.latest:
    - refresh: true

git:
  pkg.latest:
    - refresh: true

bind-utils:
  pkg.latest:
    - refresh: true

yum-utils:
  pkg.latest:
    - refresh: true

iptables-services:
  pkg.latest:
    - refresh: true

bash-completion:
  pkg.latest:
    - refresh: true

kexec-tools:
  pkg.latest:
    - refresh: true

sos:
  pkg.latest:
    - refresh: true

psacct:
  pkg.latest:
    - refresh: true

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-arptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-ip6tables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-call-iptables:
  sysctl.present:
    - value: 1

net.bridge.bridge-nf-filter-pppoe-tagged:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-filter-vlan-tagged:
  sysctl.present:
    - value: 0

net.bridge.bridge-nf-pass-vlan-input-dev:
  sysctl.present:
    - value: 0

/usr/sbin/modprobe:
  file.symlink:
    - target: /sbin/modprobe

/usr/bin/mkdir:
  file.symlink:
    - target: /bin/mkdir

/usr/bin/bash:
  file.symlink:
    - target: /bin/bash

