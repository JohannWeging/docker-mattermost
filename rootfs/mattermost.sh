#!/bin/bash
export MM_FileSettings_Directory=${MM_FileSettings_Directory:-"/data"}
export MM_ServiceSettings_ListenAddress=${MM_ServiceSettings_ListenAddress:-":3000"}

mkdir -p /data/
chown mattermost:mattermost /data

CONF_TEMPLATE_PATH=/opt/mattermost/config/config.json.tmpl
CONF_PATH=/opt/mattermost/config/config.json


gosu mattermost consul-template -once -consul-addr=' ' -vault-addr=' ' -consul-retry="false" -template "${CONF_TEMPLATE_PATH}:${CONF_PATH}"
cd /opt/mattermost/bin
gosu mattermost /opt/mattermost/bin/platform -c /opt/mattermost/config/config.json
