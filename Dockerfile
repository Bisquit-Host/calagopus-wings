# kopia from our fork: v0.23.1 plus parallel tar restore and large object read-ahead.
# To update, push to Turbovadim/kopia and bump KOPIA_REF.
FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS kopia
ARG KOPIA_REF=5a68fdd77630db1316577e341d020bfda3944b9f
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
ADD https://github.com/Turbovadim/kopia/archive/${KOPIA_REF}.tar.gz /tmp/kopia.tar.gz
RUN tar -xzf /tmp/kopia.tar.gz --strip-components=1
RUN --mount=type=cache,target=/go/pkg/mod \
	--mount=type=cache,target=/root/.cache/go-build \
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath \
	-ldflags "-s -w -X github.com/kopia/kopia/repo.BuildVersion=0.23.1 -X github.com/kopia/kopia/repo.BuildInfo=bisquit-${KOPIA_REF}" \
	-o /out/kopia .

FROM alpine:latest

RUN apk add --no-cache ca-certificates coreutils curl btrfs-progs xfsprogs-extra zfs restic nftables conntrack-tools openssh-client && \
	update-ca-certificates
RUN rm -rf /var/lib/apt/lists/*

COPY --from=kopia /out/kopia /usr/bin/kopia

# Add calagopus-wings and entrypoint
ARG TARGETPLATFORM
COPY .docker/${TARGETPLATFORM#linux/}/calagopus-wings /usr/bin/calagopus-wings

ENV OCI_CONTAINER=official

ENTRYPOINT ["/usr/bin/calagopus-wings"]
