FROM alpine

RUN set -x \
    && apk add --update --no-cache ucarp

ENV KARP_INTERFACE=
ENV KARP_HOST_IP=
ENV KARP_VIRTUAL_IP 192.168.100.1
ENV KARP_SUBNET 24
ENV KARP_SERVER_ID 10
ENV KARP_PASSWORD RAnDoM_max16char
ENV KARP_UPSCRIPT /etc/ucarp/vip-up-default.sh
ENV KARP_DOWNSCRIPT /etc/ucarp/vip-down-default.sh
ENV KARP_EXTRA_FLAGS=
ENV KARP_DEBUG=

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]
