# SimpleTimeService

Minimal Go HTTP microservice that responds on **`GET /`** with JSON:

```json
{
  "timestamp": "2026-04-07T12:00:00.000000000Z",
  "ip": "203.0.113.42"
}
```

- **`timestamp`**: current UTC time (RFC3339 with nanoseconds).
- **`ip`**: client address, using `X-Forwarded-For` / `X-Real-Ip` when present (e.g. behind Ingress), otherwise the direct remote address.

The server listens on **port 8080**. The container image runs as the **non-root** `nonroot` user (UID 65532) from Google’s distroless base image.

## Prerequisites

- [Go](https://go.dev/dl/) 1.23+ (for local builds)
- [Docker](https://docs.docker.com/get-docker/) (to build and push the image)
- [kubectl](https://kubernetes.io/docs/tasks/tools/) and a reachable Kubernetes cluster (to deploy)

## Run locally

```bash
go run .
```

Example:

```bash
curl -s http://127.0.0.1:8080/
```

## Build and push the container image

Build a small static binary and image (multi-stage build; runtime is distroless):

```bash
docker build -t YOUR_DOCKERHUB_USERNAME/simpletimeservice:latest .
```

Log in to Docker Hub and push (use your real username and tag):

```bash
docker login
docker push YOUR_DOCKERHUB_USERNAME/simpletimeservice:latest
```

**Before sharing this repo or asking others to deploy**, edit `microservice.yml` and replace `YOUR_DOCKERHUB_USERNAME` in the Deployment `image` field with your Docker Hub username (and tag if not `latest`).

There are **no API keys or secrets** in this project; do not add any to the repository.

## Deploy to Kubernetes

One manifest file defines the namespace, Deployment, and **ClusterIP** Service (not LoadBalancer):

```bash
kubectl apply -f microservice.yml
```

Check pods:

```bash
kubectl get pods -n simpletimeservice
```

### Call the service from your machine

Because the Service is ClusterIP, use port-forward:

```bash
kubectl port-forward -n simpletimeservice svc/simpletimeservice 8080:80
curl -s http://127.0.0.1:8080/
```

From another pod in the cluster:

```bash
kubectl run -n simpletimeservice curl --rm -it --restart=Never --image=curlimages/curl -- curl -s http://simpletimeservice.simpletimeservice.svc.cluster.local/
```

## Project layout

| File             | Purpose                          |
|------------------|----------------------------------|
| `main.go`        | HTTP server and JSON handler     |
| `go.mod`         | Go module definition             |
| `Dockerfile`     | Multi-stage build, non-root user |
| `microservice.yml` | Namespace, Deployment, Service |
| `.dockerignore`  | Smaller build context            |

## Public Git repository

Push this directory to a public host (GitHub, GitLab, Bitbucket, etc.) after removing or avoiding any private credentials. The image name in `microservice.yml` should point at your **public** Docker Hub image so reviewers can pull it without extra steps beyond `kubectl apply`.
