#!/bin/bash
PROJECT_NAME="<PROJECT_NAME>"
ROOT_DIR="<ROOT_DIR>"
STORAGE_ACCOUNT_ID="<STORAGE_ACCOUNT_ID>"

# wait until all installers are finished
while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 30; done;
# update
DEBIAN_FRONTEND="noninteractive" apt-get -qy update
# wait until all installers are finished
while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 30; done;
# update
DEBIAN_FRONTEND="noninteractive" apt-get -qy update
# install additional packages here
DEBIAN_FRONTEND="noninteractive" apt-get -qy install jq 

# create status service
FRONTEND_STATUS_SERVICE_FILE=/etc/systemd/system/${PROJECT_NAME}-frontend-status.service
cat <<-EOF > ${FRONTEND_STATUS_SERVICE_FILE}
[Unit]
Description=run frontend status 

[Service]
Type=simple
WatchdogSec=3min
RestartSec=1min
Restart=always
ExecStart=${ROOT_DIR}/frontend/status.sh "<PROJECT_NAME>" "<ROOT_DIR>" "<STORAGE_ACCOUNT_ID>"

[Install]
WantedBy=multi-user.target
EOF

# enable services
systemctl daemon-reload
systemctl enable --now ${PROJECT_NAME}-frontend-status.service
