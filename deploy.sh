#!/bin/bash

TAG_VERSION=${VERSION%.*}
docker push johannweging/mattermost:${TAG_VERSION}

if [[ "${VERSION}" == "${LATEST}" ]]; then
    docker tag johannweging/mattermost:${TAG_VERSION} johannweging/mattermost:latest
    docker push johannweging/mattermost:latest
fi
