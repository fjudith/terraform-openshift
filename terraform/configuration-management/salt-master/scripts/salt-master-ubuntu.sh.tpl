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
  openssl \
  reclass && \
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
  salt-master=${SALT_VERSION}* \
  salt-minion=${SALT_VERSION}* \
  salt-ssh=${SALT_VERSION}* \
  salt-syndic=${SALT_VERSION}* \
  salt-cloud=${SALT_VERSION}* \
  salt-api=${SALT_VERSION}*

cat << EOF > /etc/salt/grains
role: ${ROLE}
EOF

cat << EOF > /etc/salt/master.d/auto-accept.conf
open_mode: True
auto_accept: True
EOF

cat << EOF > /etc/salt/minion.d/master.conf
master: localhost
timeout: 30
EOF

#############################################
# Install SaltGUI
#############################################
echo "Install SaltGUI"

echo "add a user for the frontend ${SALT_USER}:${SALT_USER}" && \
if getent passwd ${SALT_USER} > /dev/null 2>&1; then 
  echo "user \"${SALT_USER}\" already exists" ; 
else 
  useradd -m -s/bin/bash -p $(openssl passwd -1 ${SALT_USER}) ${SALT_USER}
fi

cat << EOF > /etc/salt/master.d/saltgui.conf
external_auth:
  pam:
    salt:
      - .*
      - '@runner'
      - '@wheel'
      - '@jobs'

rest_cherrypy:
    port: 3333
    host: 0.0.0.0
    disable_ssl: true
    app: /srv/saltgui/index.html
    static: /srv/saltgui/static
    static_path: /static
EOF

cd /opt && curl -L https://github.com/erwindon/SaltGUI/archive/${SALTGUI_VERSION}.tar.gz | tar -xvzf - && \
ln -fs /opt/SaltGUI-${SALTGUI_VERSION}/saltgui /srv/saltgui && \
systemctl enable salt-master && \
systemctl enable salt-minion && \
systemctl enable salt-api && \
systemctl daemon-reload && \
systemctl restart salt-master && \
systemctl restart salt-minion && \
systemctl restart salt-api