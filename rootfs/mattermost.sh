#!/bin/bash
export MM_FileSettings_Directory=${MM_FileSettings_Directory:-"/data"}
export MM_ServiceSettings_ListenAddress=${MM_ServiceSettings_ListenAddress:-":3000"}
mkdir -p /data/
chown mattermost:mattermost /data

DEFAULT_CONF_PATH=/opt/mattermost/config/config.json.default
CONF_PATH=/opt/mattermost/config/config.json
ENV_PATH=/opt/mattermost/config/env.sh

[ ! -e ${DEFAULT_CONF_PATH} ] && cp ${CONF_PATH} ${DEFAULT_CONF_PATH}
chown mattermost:mattermost ${DEFAULT_CONF_PATH}

if [ ! -e ${ENV_PATH} ]; then
    echo "generating default env"
    echo "" > ${ENV_PATH}
    for section in $(jq -r "keys[]" ${DEFAULT_CONF_PATH}); do
        for key in $(jq -r ".${section} | keys[]" ${DEFAULT_CONF_PATH}); do
            v=$(jq ".${section}.${key}" ${DEFAULT_CONF_PATH})
            echo "export MM_${section}_${key}=\${MM_${section}_${key}:-${v}}" >> ${ENV_PATH}
        done
    done
fi

echo "loading default env"
source ${ENV_PATH}
echo "writing config file"

cp ${DEFAULT_CONF_PATH} /tmp/config.json
for section in $(jq -r "keys[]" ${DEFAULT_CONF_PATH}); do
    for key in $(jq -r ".${section} | keys[]" ${DEFAULT_CONF_PATH}); do
        v=MM_${section}_${key}
        if [[ ${!v} == "[]" ]]; then
            jq --argjson "inarg" "${!v}" ".${section}.${key} |= \$inarg" /tmp/config.json > /tmp/config.json.new
        elif [[ ${!v} == "{}" ]]; then
            jq --argjson "inarg" "${!v}" ".${section}.${key} |= \$inarg" /tmp/config.json > /tmp/config.json.new
        else
            jq --arg "inarg" "${!v}" ".${section}.${key} |= \$inarg" /tmp/config.json > /tmp/config.json.new
        fi
        mv /tmp/config.json.new /tmp/config.json
    done
done

mv /tmp/config.json ${CONF_PATH}
chown mattermost:mattermost ${CONF_PATH}

cd /opt/mattermost/bin
gosu mattermost /opt/mattermost/bin/platform -c /opt/mattermost/config/config.json
