# Builds kopia from our fork. Bisquit Build publishes it as ghcr.io/bisquit-host/calagopus-wings/kopia:<ref>,
# and the main Dockerfile copies the binary from there.
FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS build
ARG KOPIA_REF
ARG TARGETOS
ARG TARGETARCH
WORKDIR /src
ADD https://github.com/Turbovadim/kopia/archive/${KOPIA_REF}.tar.gz /tmp/kopia.tar.gz
RUN tar -xzf /tmp/kopia.tar.gz --strip-components=1
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath \
	-ldflags "-s -w -X github.com/kopia/kopia/repo.BuildVersion=0.23.1 -X github.com/kopia/kopia/repo.BuildInfo=bisquit-${KOPIA_REF}" \
	-o /out/kopia .

FROM scratch
LABEL org.opencontainers.image.source=https://github.com/Bisquit-Host/calagopus-wings
COPY --from=build /out/kopia /kopia
