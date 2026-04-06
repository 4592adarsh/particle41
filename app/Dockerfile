

FROM --platform=$BUILDPLATFORM golang:1.23-alpine AS build
WORKDIR /src

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

ARG TARGETOS=linux
ARG TARGETARCH=amd64
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -trimpath -ldflags="-s -w" -o /simpletimeservice .


FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /simpletimeservice /simpletimeservice

EXPOSE 8080
USER nonroot:nonroot
ENTRYPOINT ["/simpletimeservice"]
