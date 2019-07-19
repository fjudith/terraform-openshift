#!/bin/bash -e

echo "Performance Tuning"

#############################################
# Install Python
#############################################
echo "Install Python"

yum update -y && \
yum install -y \
  htop \
  git \
  curl \
  jq \
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

#Cloudflare record dns monitor
cat << SCRIPT > /opt/update_cloudflare_record.sh
#!/bin/bash

# A bash script to update a Cloudflare DNS A record with the external IP of the source machine
# Used to provide DDNS service for my home
# Needs the DNS record pre-creating on Cloudflare

# Proxy - uncomment and provide details if using a proxy
#export https_proxy=http://<proxyuser>:<proxypassword>@<proxyip>:<proxyport>

# Cloudflare zone is the zone which holds the record
zone=${CLOUDFLARE_ZONE}
# dnsrecord is the A record which will be updated
dnsrecord=${CLOUDFLARE_RECORD}

## Cloudflare authentication details
## keep these private
cloudflare_auth_email=${CLOUDFLARE_EMAIL}
cloudflare_auth_key=${CLOUDFLARE_TOKEN}


# Get the current external IP address
ip=$(curl -s -X GET https://checkip.amazonaws.com)

echo "Current IP is $ip"

if host $dnsrecord 1.1.1.1 | grep "has address" | grep "$ip"; then
  echo "$dnsrecord is currently set to $ip; no changes needed"
  exit
fi

# if here, the dns record needs updating

# get the zone id for the requested zone
zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "X-Auth-Key: $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "Zoneid for $zone is $zoneid"

# get the dns record id
dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "X-Auth-Key: $cloudflare_auth_key" \
  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

echo "DNSrecordid for $dnsrecord is $dnsrecordid"

# update the record
curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
  -H "X-Auth-Email: $cloudflare_auth_email" \
  -H "X-Auth-Key: $cloudflare_auth_key" \
  -H "Content-Type: application/json" \
  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}" | jq
SCRIPT

chmod +x /opt/update_cloudflare_record.sh
cat << EOF | crontab
*/1 * * * * /opt/update_cloudflare_record.sh >/dev/null 2>&1

EOF