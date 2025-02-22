FROM alpine:latest as alpine_runner
# Install curl
RUN apk add --no-cache curl

FROM golang:alpine as app-builder
WORKDIR /go/src/app
COPY . .
RUN go mod download
RUN CGO_ENABLED=0 go install -ldflags '-extldflags "-static"' -tags timetzdata -buildvcs=false

FROM alpine_runner
COPY --from=app-builder /go/bin/nirn-proxy /nirn-proxy
# the tls certificates:
# NB: this pulls directly from the upstream image, which already has ca-certificates:
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
EXPOSE 9000
EXPOSE 8080
ENTRYPOINT ["/nirn-proxy"]