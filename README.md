# Particle41 Assignment: Full Stack Infrastructure & Deployment

This repository contains the complete solutions for **Task 1** (Minimalist Application Development) and **Task 2** (Terraform and AWS EKS Deployment).

---

## Task 1: SimpleTimeService (Kubernetes App)

**Directory:** `/app`

A minimal microservice developed in Go that returns a pure JSON response containing the current UTC timestamp and the visitor's IP address. 

- **Container Best Practices**: Built natively via a multi-stage Dockerfile leveraging `golang:1.23-alpine`. The final runtime implements a totally distroless architecture (`gcr.io/distroless/static-debian12:nonroot`), ensuring the container operates securely as a **non-root user** with zero shell bloat.
- **Multi-Architecture Support**: The `Dockerfile` natively processes multi-architecture compilation (`TARGETOS` and `TARGETARCH`), allowing deployment to both AWS EKS (amd64) and local Minikube / Apple Silicon (arm64) securely.
- **Public Registry**: Continuously pushed to DockerHub via GitHub Actions pipelines.

### Deployment Instructions

To deploy the application securely alongside its ClusterIP service to a running Kubernetes cluster:

```bash
cd app
kubectl apply -f microservice.yml
```

*Note: `kubectl apply -f microservice.yml` is the sole command required. The manifest natively invokes the application via DockerHub securely and spins up exactly two replicas internally.*

You can optionally port-forward to test the live endpoint locally:
```bash
kubectl port-forward svc/simpletimeservice 8080:80
curl http://127.0.0.1:8080/
```

---

## Task 2: AWS EKS & VPC Infrastructure (Terraform)

**Directory:** `/terraform/development`

Provisions a fully compliant AWS Virtual Private Cloud alongside a managed Elastic Kubernetes Service.
- **VPC Configuration:** Generates a secure network spanning 2 Public Subnets and 2 Private Subnets.
- **EKS Compute Nodes:** Launches an integrated Managed Node Group containing precisely 2 `m6a.large` instances explicitly restricted inside the *private subnets*, adhering flawlessly to requirements. 
- **Configuration Design Decisions:** Local configuration elements are explicitly locked down dynamically inside `locals.tf` rather than external inputs to seamlessly prevent runtime manipulation across test suites.

### Authentication

**Do not commit AWS credentials to this repository.** 

Before execution, you must securely authenticate your session with AWS by directly running `aws configure`:
```bash
aws configure
```
Provide your  `AWS Access Key ID`, `AWS Secret Access Key`, and set your default deployment region (e.g., `us-east-1`).

### Deployment Instructions

Navigate to the Terraform deployment root directory:
```bash
cd terraform/development
```

1. **Initialize Terraform** (Downloads the securely audited AWS providers and child modules):
```bash
terraform init
```

2. **Preview Infrastructure Plan**:
```bash
terraform plan
```

3. **Provision Resources**:
```bash
terraform apply
```
*(Type `yes` when prompted to approve and generate the VPC and EKS Cluster. Both stacks will launch natively and simultaneously).*

---

## Extra credit


### Kubernetes manifest best practices

- **Pod CPU and memory** — The Deployment defines a `resources` block with **requests** and **limits** so the scheduler can place pods predictably and the workload is bounded.
  - See: [app/microservice.yml (resource requests / limits)](https://github.com/4592adarsh/particle41/blob/ae91a5d4c224ac890324351cd17fc20f9d9e0ccf/app/microservice.yml#L25)

### Fluent Bit sidecar

- **Log shipping** — A **Fluent Bit** sidecar runs alongside the app container in the same pod (for example to forward logs to a collector or cloud logging).
  - See: [app/microservice.yml (Fluent Bit sidecar)](https://github.com/4592adarsh/particle41/blob/ae91a5d4c224ac890324351cd17fc20f9d9e0ccf/app/microservice.yml#L44)

### Terraform remote backend (S3 + DynamoDB)

- **Remote state and locking** — Terraform is wired for an **S3** backend and **DynamoDB** state locking instead of a local `terraform.tfstate` file.
- **Enable it in your account** — In `terraform/development/provider.tf`, **uncomment** the `backend "s3" { ... }` block and set **`bucket`**, **`key`**, **`region`**, **`dynamodb_table`**, and **`encrypt`** to your real S3 bucket and DynamoDB lock table (see the commented example in-repo).
  - See: [terraform/development/provider.tf (backend block)](https://github.com/4592adarsh/particle41/blob/ae91a5d4c224ac890324351cd17fc20f9d9e0ccf/terraform/development/provider.tf#L2)

### CI/CD pipeline (GitHub Actions)

- **Build and publish** — A GitHub Actions workflow builds the Docker image, pushes it to the container registry, and **updates `app/microservice.yml`** with the new image tag.
- **GitOps / Argo CD** — If **Argo CD** watches that manifest in Git, it can sync the cluster to the new image automatically after each successful run.
  - Workflow: [GitHub Actions run example](https://github.com/4592adarsh/particle41/actions/runs/24061076727)

---

## Notes & gotchas

- **Docker Hub — push still needs credentials** — A *public* image can be pulled without logging in, but **pushing** from CI (or your laptop) always requires authentication. Store a [Docker Hub access token](https://docs.docker.com/security/for-developers/access-tokens/) (not your account password) as a GitHub Actions secret (for example `DOCKERHUB_TOKEN`) and use it with `docker/login-action`.

- **GitHub Actions — write access to the repo** — The workflow commits manifest updates (image tag changes) back to the repository. The default `GITHUB_TOKEN` must be allowed to **read and write** repository contents (`permissions: contents: write` in the workflow, and under **Settings → Actions → General**, avoid overly restrictive *Workflow permissions* that block pushes). This applies even when the repository is **public**; visibility does not grant the token push rights by itself if permissions are tightened at the org/repo level.

- **`git pull` before you `git push`** — After each push to `main`, the pipeline may commit an updated image tag in **`app/microservice.yml`**. Always **`git pull --rebase`** (or merge) before pushing local changes so you do not hit a **non-fast-forward** / merge conflict on that file.
