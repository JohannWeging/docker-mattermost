FROM johannweging/base-alpine:edge

ARG MATTERMOST_VERSION

ENV MATTERMOST_VERSION=${MATTERMOST_VERSION} CONSUL_TEMPLATE_VERSION=0.19.5

# install mattermost
RUN set -x \
&& apk add --update --no-cache jq bash

RUN set -x \
&& curl https://releases.hashicorp.com/consul-template/${CONSUL_TEMPLATE_VERSION}/consul-template_${CONSUL_TEMPLATE_VERSION}_linux_amd64.tgz > /tmp/consul-template.tgz \
&& cd /tmp \
&& tar -xf consul-template.tgz \
&& mv consul-template /usr/bin \
&& cd / \
&& mkdir -p /opt \
&& mkdir -p /go \
&& export GOPATH=/go \
&& BUILD_PATH=${GOPATH}/src/github.com/mattermost \
&& mkdir -p ${GOPATH} \
&& mkdir -p ${BUILD_PATH} \
&& apk --no-cache add --virtual .deps go git mercurial nodejs-npm make g++ \
&& go get -v github.com/tools/godep \
&& npm update npm --global -i \
&& cd ${BUILD_PATH} \
&& git clone -b v${MATTERMOST_VERSION} --depth 1 https://github.com/mattermost/mattermost-server.git \
&& ln -sf mattermost-server platform \
&& cd mattermost-server \
&& sed -i.org 's/sudo //g' Makefile \
&& make build-linux BUILD_NUMBER=${MATTERMOST_VERSION} \
&& curl -SL https://releases.mattermost.com/${MATTERMOST_VERSION}/mattermost-${MATTERMOST_VERSION}-linux-amd64.tar.gz > /tmp/mattermost.tar.gz \
&& tar -C /opt -xzf /tmp/mattermost.tar.gz \
&& cp -f ${GOPATH}/bin/platform /opt/mattermost/bin/platform \
&& cd / \
&& apk del .deps \
&& rm -rf /go /tmp/* /root/.npm /root/.node-gyp /usr/lib/go/pkg /usr/lib/node_modules

# setup mattermost user
RUN set -x \
&& addgroup mattermost \
&& adduser -D -G mattermost mattermost

ADD rootfs /

RUN set -x \
&& chown -R mattermost:mattermost /opt/mattermost \
&& chmod +x /mattermost.sh

EXPOSE 3000

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/mattermost.sh"]
