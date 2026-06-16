# GKE + ArgoCD Terraform Setup

A production-grade (but cost-optimised) Terraform configuration that provisions a **GKE Standard** cluster inside a **custom VPC** in `asia-south1` and deploys **ArgoCD** via the Helm provider.

---

## File Structure

```
gke-argocd/
├── versions.tf       # Terraform, provider versions + GCS backend
├── variables.tf      # All input variables
├── terraform.tfvars  # Pre-filled values (edit project_id if needed)
├── providers.tf      # google / kubernetes / helm providers (dynamic auth)
├── vpc.tf            # Custom VPC + subnet + secondary IP ranges + firewall
├── iam.tf            # Dedicated GKE node SA with least-privilege roles
├── gke.tf            # GKE Standard cluster
├── node_pool.tf      # 1 × e2-standard-2 node pool
├── argocd.tf         # ArgoCD Helm release + namespace
└── outputs.tf        # Useful outputs + reminders
```

---

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | ≥ 1.7.0 |
| gcloud CLI | Latest |
| kubectl | Latest |
| helm | ≥ 3.x (optional, for manual ops) |

---

## Step-by-Step Deployment

### 1. Authenticate with GCP

```bash
gcloud auth login
gcloud auth application-default login
gcloud config set project project-68d4f10e-27fc-4ab1-ab5
```

### 2. Enable required GCP APIs

```bash
gcloud services enable \
  container.googleapis.com \
  compute.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  storage.googleapis.com
```

### 3. Create the GCS backend bucket (one-time)

```bash
gsutil mb -p project-68d4f10e-27fc-4ab1-ab5 \
          -l asia-south1 \
          gs://terraform
```

> **Note:** GCS bucket names are globally unique. If `terraform` is taken, pick another name and update `versions.tf` and `terraform.tfvars`.

### 4. Initialise Terraform

```bash
cd gke-argocd
terraform init
```

### 5. Review the plan

```bash
terraform plan
```

### 6. Apply (provisions cluster + deploys ArgoCD)

```bash
terraform apply
```

> ⏱️ Expect **8–15 minutes** total:
> - GKE cluster creation: ~8–10 min
> - Node pool: ~2 min
> - ArgoCD Helm deploy: ~2–3 min

---

## Post-Apply: Access ArgoCD

### Configure kubectl

```bash
gcloud container clusters get-credentials gke-argocd-cluster \
  --zone asia-south1-a \
  --project project-68d4f10e-27fc-4ab1-ab5
```

### Get the ArgoCD UI URL

```bash
kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Open `http://<EXTERNAL-IP>` in your browser.

### Get the initial admin password

```bash
kubectl get secret argocd-initial-admin-secret -n argocd \
  -o jsonpath='{.data.password}' | base64 -d && echo
```

Login with username `admin` and the password above.

---

## Cost Breakdown (asia-south1)

| Resource | Details | Est. Cost/month |
|---|---|---|
| GKE Control Plane | 1 free zonal cluster (GKE free tier) | **$0** |
| 1 × e2-standard-2 | 2 vCPU / 8 GB RAM | ~$49 |
| GCP LoadBalancer | ArgoCD UI | ~$15–18 |
| Boot disk | 50 GB pd-standard | ~$2 |
| GCS state bucket | ~1 MB | ~$0.02 |
| **Total** | | **~$66–69/month** |

> 💡 Your $300 free trial gives roughly **4 months** at this rate.  
> **Always run `terraform destroy` when done experimenting!**

---

## Tearing Down

```bash
terraform destroy
```

This removes the GKE cluster, node pool, VPC, and ArgoCD namespace — but **not** the GCS backend bucket (to preserve your state history). Delete it manually if needed:

```bash
gsutil rm -r gs://terraform
```

---

## Security Notes

| Item | Status | Action |
|---|---|---|
| ArgoCD TLS | ⚠️ HTTP only (`insecure=true`) | Add cert-manager + LetsEncrypt for prod |
| Cluster deletion protection | Off | Set `deletion_protection = true` for prod |
| Node SA | ✅ Least-privilege | — |
| Workload Identity | ✅ Enabled | — |
| Shielded VMs | ✅ Enabled | — |
| Legacy metadata API | ✅ Disabled | — |
