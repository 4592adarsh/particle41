# Step 1: Build Stage
FROM golang:1.23-alpine AS build
WORKDIR /src

COPY go.mod go.sum* ./
RUN go mod download

COPY . .

# HARDCODE GOARCH to amd64 to force the correct binary format
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w" -o /simpletimeservice .

# Step 2: Final Image
FROM gcr.io/distroless/static-debian12:nonroot
COPY --from=build /simpletimeservice /simpletimeservice

EXPOSE 8080
USER 65532:65532 
ENTRYPOINT ["/simpletimeservice"]