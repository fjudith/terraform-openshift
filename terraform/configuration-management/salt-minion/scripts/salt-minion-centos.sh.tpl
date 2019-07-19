#!/bin/bash -e

echo "Performance Tuning"

#############################################
# Install Python
#############################################
echo "Install Python"

yum update -y && \
yum install -y \
  htop \
  curl \
  net-tools \
  gnupg2 \
  jq \
  epel-release \
  gcc \
  make \
  dmidecode \
  kernel-devel \
  openssl-devel \
  bzip2-devel \
  libffi-devel \
  augeas \
  openssl && \
yum install -y \
  python36 \
  python36-devel \
  python36-pip \
  python36-setuptools

pip3 install \
  python-augeas \
  boto \
  boto3 \
  botocore \
  cffi \
  cherrypy \
  croniter \
  python-dateutil \
  docker-py \
  gitdb \
  gitpython \
  ioflo \
  libnacl \
  m2crypto \
  mako \
  msgpack-pure \
  msgpack-python \
  pycparser \
  pycrypto \
  pycryptodome \
  pygit2 \
  python-gnupg \
  pyaml \
  pyzmq \
  raet \
  smmap \
  timelib \
  tornado \
  python-git \
  netaddr \
  pyinotify \
  ws4py

#############################################
# Install Saltstack
#############################################
echo "Install Saltstack"

rpm --import https://repo.saltstack.com/py3/redhat/7/x86_64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub && \

cat << EOF > /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for RHEL/CentOS ${RELEASE_VERSION} PY3
baseurl=https://repo.saltstack.com/py3/redhat/${RELEASE_VERSION}/${ARCHITECTURE}/archive/${SALT_VERSION}
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/py3/redhat/${RELEASE_VERSION}/${ARCHITECTURE}archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub
EOF

yum clean expire-cache && \
yum install -y \
  salt-minion \
  salt-ssh

cat << EOF > /etc/salt/grains
role: ${ROLE}
EOF

cat << EOF > /etc/salt/minion.d/master.conf
master: ${SALT_MASTER_HOST}
EOF

systemctl enable salt-minion && \
systemctl daemon-reload && \
systemctl restart salt-minion
