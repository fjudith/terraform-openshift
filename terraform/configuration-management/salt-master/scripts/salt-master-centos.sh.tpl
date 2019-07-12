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
  salt-master \
  salt-minion \
  salt-ssh \
  salt-syndic \
  salt-cloud \
  salt-api \

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
