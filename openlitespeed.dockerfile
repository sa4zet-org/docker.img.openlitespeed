FROM ghcr.io/sa4zet-org/docker.img.debian:latest AS build-stage

ARG docker_img
ENV DOCKER_TAG=$docker_img

COPY etc/ /etc/
COPY --chmod=700 entrypoint.sh /entrypoint.sh
COPY usr/ /usr

RUN apt-get update \
  && apt-get -y install \
    openlitespeed \
    lsphp84 \
    lsphp84-curl \
    lsphp84-common \
    lsphp84-sqlite3 \
    lsphp84-opcache \
  && mkdir -p /var/lib/php/sessions

RUN apt-get --purge -y autoremove \
    && apt-get clean \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && rm -rf /usr/local/lsws/Example

FROM scratch AS final-stage
COPY --from=build-stage / /

ENV PATH="/usr/local/lsws/bin/:/usr/local/lsws/admin/misc:${PATH}" \
  DOCKER_TAG=ghcr.io/sa4zet-org/docker.img.openlitespeed

HEALTHCHECK \
  --interval=3m \
  --retries=2 \
  --timeout=2s \
  CMD /usr/local/lsws/bin/lswsctrl status | grep 'litespeed is running' || exit 1

ENTRYPOINT ["/entrypoint.sh"]
WORKDIR /vhosts/
