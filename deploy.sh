#!/bin/bash
docker push johannweging/mattermost:${VERSION}

if [[ "${VERSON}" == "${LATEST}" ]]; then
    docker tag johannweging/mattermost:${VERSION} johannweging/mattermost:latest
    docker push johannweging/mattermost:latest
fi
