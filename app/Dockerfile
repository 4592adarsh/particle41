FROM golang:1.23-alpine AS build
WORKDIR /src

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
# Default amd64 matches typical Minikube / cloud nodes. On Apple Silicon, `docker build`
# otherwise produces arm64 and you get "exec format error" on amd64 clusters.
ARG TARGETOS=linux
ARG TARGETARCH=amd64
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -ldflags="-s -w" -o /simpletimeservice .


# Keep runtime arch in sync with the binary (important when building on Apple Silicon).
ARG TARGETPLATFORM=linux/amd64
FROM --platform=${TARGETPLATFORM} gcr.io/distroless/static-debian12:nonroot
COPY --from=build /simpletimeservice /simpletimeservice

EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/simpletimeservice"]
