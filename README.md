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
Provide your officially granted `AWS Access Key ID`, `AWS Secret Access Key`, and set your default deployment region (e.g., `us-east-1`).

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
