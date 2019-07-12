#!/bin/bash -e

echo "Performance Tuning"

#############################################
# Install Python
#############################################
echo "Install Python"

apt-get update -yqq && \
apt-get install -yqq --no-install-recommends \
  curl \
  net-tools \
  gnupg2 \
  lsb-release \
  gcc \
  make \
  dmidecode \
  debconf-utils \
  software-properties-common \
  libssl-dev \
  libbzip2-dev \
  libffi-dev \
  augeas-lenses \
  augeas-tools \
  openssl && \
apt-get install -yqq --no-install-recommends \
  python3 \
  python3-dev \
  python3-pip \
  python3-setuptools \
  
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

curl -fsSL http://repo.saltstack.com/py3/ubuntu/18.04/amd64/archive/${SALT_VERSION}/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && \
echo "deb http://repo.saltstack.com/py3/ubuntu/18.04/amd64/archive/${SALT_VERSION} bionic main" > /etc/apt/sources.list.d/saltstack.list && \
echo "install salt-master and salt-api, dependencies" && \
apt-get update -yqq && \
apt-get install --no-install-recommends -yq \
  python3-augeas \
  python3-boto \
  python3-boto3 \
  python3-botocore \
  python3-cherrypy3 \
  python3-croniter \
  python3-git \
  python3-pip \
  python3-ioflo \
  python3-raet \
  python3-setuptools \
  python3-timelib \
  python3-netaddr \
  python3-pyinotify \
  python3-ws4py \
  salt-minion=${SALT_VERSION}* \
  salt-ssh=${SALT_VERSION}* \
  reclass

cat << EOF > /etc/salt/grains
role: ${ROLE}
EOF

cat << EOF > /etc/salt/minion.d/master.conf
master: ${SALT_MASTER_HOST}
EOF

systemctl enable salt-minion && \
systemctl daemon-reload && \
systemctl restart salt-minion