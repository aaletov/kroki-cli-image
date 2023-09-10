ARG GO_BUILDER_IMAGE
ARG RUNTIME_IMAGE
FROM ${GO_BUILDER_IMAGE} as builder
ARG KROKI_VERSION
RUN go install github.com/yuzutech/kroki-cli/cmd/kroki@${KROKI_VERSION} && \
	mv $(go env GOPATH)/bin/kroki /kroki
FROM ${RUNTIME_IMAGE}
COPY --from=builder /kroki .
ENTRYPOINT ["/kroki"]
