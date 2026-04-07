# Step 1: Build Stage
FROM golang:1.23-alpine AS build
WORKDIR /src

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

# Support Multi-Architecture Builds
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS:-linux} GOARCH=${TARGETARCH:-amd64} \
    go build -trimpath -ldflags="-s -w" -o /simpletimeservice .

# Step 2: Final Image
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /simpletimeservice /simpletimeservice

EXPOSE 8080
USER 65532:65532 
ENTRYPOINT ["/simpletimeservice"]