# kopia from our fork (Turbovadim/kopia): v0.23.1 plus parallel tar restore and large object read-ahead.
# Bisquit Build publishes the image for this ref when it is missing, so bumping the ref is enough.
ARG KOPIA_REF=5a68fdd77630db1316577e341d020bfda3944b9f
FROM ghcr.io/bisquit-host/calagopus-wings/kopia:${KOPIA_REF} AS kopia
FROM alpine:latest

RUN apk add --no-cache ca-certificates coreutils curl btrfs-progs xfsprogs-extra zfs restic nftables conntrack-tools openssh-client && \
	update-ca-certificates
RUN rm -rf /var/lib/apt/lists/*

COPY --from=kopia /kopia /usr/bin/kopia

# Add calagopus-wings and entrypoint
ARG TARGETPLATFORM
COPY .docker/${TARGETPLATFORM#linux/}/calagopus-wings /usr/bin/calagopus-wings

ENV OCI_CONTAINER=official

ENTRYPOINT ["/usr/bin/calagopus-wings"]
