#!/bin/bash
PROJECT_NAME="<PROJECT_NAME>"
ROOT_DIR="<ROOT_DIR>"
STORAGE_ACCOUNT_ID="<STORAGE_ACCOUNT_ID>"
EVENT_HUB_NAMESPACE="<EVENT_HUB_NAMESPACE>"
EVENT_HUB_PATH="<EVENT_HUB_PATH>"
EVENT_HUB_KEY="<EVENT_HUB_KEY>"

# wait until all installers are finished
while fuser /var/lib/dpkg/lock >/dev/null 2>&1; do sleep 30; done;

# update
DEBIAN_FRONTEND="noninteractive" sudo apt-get -qy update
# install additional packages here
# install jq
DEBIAN_FRONTEND="noninteractive" sudo apt-get -qy install jq 

# create status service to host status process
FRONTEND_STATUS_SERVICE_FILE=/etc/systemd/system/${PROJECT_NAME}-frontend-status.service
cat <<-EOF > ${FRONTEND_STATUS_SERVICE_FILE}
[Unit]
Description=run host status 

[Service]
Type=simple
WatchdogSec=3min
RestartSec=1min
Restart=always
ExecStart=${ROOT_DIR}/frontend/status.sh "<PROJECT_NAME>" "<ROOT_DIR>" "<STORAGE_ACCOUNT_ID>" "<EVENT_HUB_NAMESPACE>" "<EVENT_HUB_PATH>" "<EVENT_HUB_KEY>"

[Install]
WantedBy=multi-user.target
EOF

# enable services
systemctl daemon-reload
systemctl enable --now ${PROJECT_NAME}-frontend-status.service
