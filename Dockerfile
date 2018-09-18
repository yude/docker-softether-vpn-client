FROM alpine:3.8 as builder
LABEL maintainer="Antoine Mary <antoinee.mary@gmail.com>" \
      contributor="Dimitri G. <dev@dmgnx.net>"

### SET ENVIRONNEMENT
ENV LANG="en_US.UTF-8"

### SETUP
RUN set -ex ; \
    apk add --no-cache --update --virtual .build-deps \
      gcc g++ make musl-dev ncurses-dev openssl-dev readline-dev cmake git ; \
    # Fetch sources
    git clone https://github.com/SoftEtherVPN/SoftEtherVPN_Stable.git ; \
    cd SoftEtherVPN_Stable ; \
    git submodule init && git submodule update ; \
    # Compile and Install
    ./configure ; \
    make ; make install ; make clean ; 


FROM alpine:3.8

COPY assets/entrypoint.sh /entrypoint.sh

RUN set -ex ; \
    addgroup -S softether ; adduser -D -H softether -g 'softether' -G softether -s /bin/sh ; \
    apk --update --no-cache add \
      libcap libcrypto1.0 libssl1.0 ncurses-libs readline su-exec ; \
    chmod +x /entrypoint.sh

COPY --from=builder /usr/vpnclient /usr/vpnclient
COPY --from=builder /usr/bin/vpnclient /usr/bin/vpnclient
COPY --from=builder /usr/vpncmd /usr/vpncmd
COPY --from=builder /usr/bin/vpncmd /usr/bin/vpncmd

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/vpnclient", "execsvc"]

