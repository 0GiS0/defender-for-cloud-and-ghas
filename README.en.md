# 🛡️ Defender for Cloud & GitHub Advanced Security - Demo

🌍 English | **[Español](README.md)**

[![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UC140iBrEZbOtvxWsJ-Tb0lQ?style=for-the-badge&logo=youtube&logoColor=white&color=red)](https://www.youtube.com/c/GiselaTorres?sub_confirmation=1) [![GitHub followers](https://img.shields.io/github/followers/0GiS0?style=for-the-badge&logo=github&logoColor=white)](https://github.com/0GiS0) [![LinkedIn Follow](https://img.shields.io/badge/LinkedIn-Follow-blue?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/giselatorresbuitrago/) [![X Follow](https://img.shields.io/badge/X-Follow-black?style=for-the-badge&logo=x&logoColor=white)](https://twitter.com/0GiS0)

---

Hey developer 👋🏻! This repository is a demo of the integration between **Microsoft Defender for Cloud** and **GitHub Advanced Security (GHAS)** for end-to-end vulnerability detection: from source code to Azure infrastructure.

This project implements the steps described in the official Microsoft guide:
📖 **[Deploy the GitHub Advanced Security integration with Microsoft Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/github-advanced-security-deploy)**

⚠️ **WARNING**: This repository contains **intentionally vulnerable** code and configurations for educational and demonstration purposes. **DO NOT use in production.**

<a href="https://youtu.be/BomDSi3UW5o">
 <img src="https://img.youtube.com/vi/BomDSi3UW5o/maxresdefault.jpg" alt="Defender for Cloud & GitHub Advanced Security" width="100%" />
</a>

---

## 🎯 Goal

Demonstrate how the combination of **GitHub Advanced Security (GHAS)** and **Microsoft Defender for Cloud** provides a complete security overview across the entire software lifecycle:

- **Shift-Left (GHAS)**: Detect vulnerabilities in source code, dependencies, and secrets _before_ they reach production.
- **Runtime & CSPM (Defender for Cloud)**: Identify misconfigurations in cloud infrastructure, container vulnerabilities, and sensitive data exposure _at runtime_.
- **Unified Vision**: Correlate findings from both tools to prioritize remediation based on real risk.
- **Code-to-Cloud**: Link code alerts to cloud resources, create security campaigns in GitHub with runtime context, and close the loop between security and engineering teams.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        GitHub Repository                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────────────┐  │
│  │ CodeQL   │  │ Secret   │  │Dependabot│  │ GitHub Actions │  │
│  │ Scanning │  │ Scanning │  │          │  │ (Build & Push) │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  └───────┬────────┘  │
│       │              │             │                │            │
│  ┌────▼──────────────▼─────────────▼────┐   ┌──────▼────────┐  │
│  │         Source Code Analysis         │   │  Docker Build  │  │
│  │  • API (.NET 6) - SQL Injection,     │   │  & Push to ACR │  │
│  │    XSS, Insecure Deserialization     │   └──────┬────────┘  │
│  │  • Web (Vue 3) - XSS, eval(),       │          │            │
│  │    hardcoded credentials             │          │            │
│  └──────────────────────────────────────┘          │            │
└────────────────────────────────────────────────────┼────────────┘
                                                     │
┌────────────────────────────────────────────────────▼────────────┐
│                      Microsoft Azure                            │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │                  Defender for Cloud                        │   │
│  │  ┌─────────┐  ┌────────────┐  ┌──────────────────────┐  │   │
│  │  │  CSPM   │  │ Defender   │  │  Defender for        │  │   │
│  │  │         │  │ for        │  │  Storage             │  │   │
│  │  │         │  │ Containers │  │                      │  │   │
│  │  └────┬────┘  └─────┬──────┘  └──────────┬───────────┘  │   │
│  └───────┼─────────────┼────────────────────┼───────────────┘   │
│          │             │                    │                    │
│  ┌───────▼──────┐ ┌────▼──────┐  ┌─────────▼──────────────┐   │
│  │  AKS Cluster │ │   ACR     │  │   Storage Account      │   │
│  │  (public,    │ │  (admin   │  │   (public, HTTP,       │   │
│  │  no RBAC)    │ │  enabled) │  │    sensitive data)     │   │
│  └──────────────┘ └───────────┘  └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **API Backend** | .NET 6 (C#) | REST API with code vulnerabilities (SQL Injection, XSS, insecure deserialization) |
| **Web Frontend** | Vue 3 + Vite | SPA with client-side vulnerabilities (XSS, `eval()`, hardcoded credentials) |
| **Infrastructure** | Terraform | Intentionally misconfigured Azure resources (AKS, ACR, Storage) |
| **Kubernetes** | YAML manifests | Insecure deployments (privileged, root, no network policies) |
| **Test Data** | CSV / JSON | Fictitious sensitive data (PII, credit cards, SSN) |

---

## 📂 Repository Structure

```
defender-for-cloud-and-ghas/
├── 📁 src/
│   ├── 📁 api/                          # API Backend (.NET 6)
│   │   ├── Controllers/
│   │   │   ├── CustomersController.cs   # SQL Injection, Path Traversal, insecure deserialization
│   │   │   └── TransactionsController.cs # Hardcoded API key, SQL Injection, IDOR
│   │   ├── Models/
│   │   │   ├── Customer.cs              # Model with sensitive data (SSN, DNI)
│   │   │   └── Transaction.cs           # Model with card data (PAN, CVV)
│   │   ├── Program.cs                   # Permissive CORS, no HTTPS, no auth middleware
│   │   ├── appsettings.json             # 🔑 Connection strings, API keys, DB credentials
│   │   ├── SensitiveDataApi.csproj      # Vulnerable NuGet dependencies
│   │   └── Dockerfile                   # No multi-stage, root, latest tag
│   │
│   └── 📁 web/                          # Frontend (Vue 3 + Vite)
│       ├── src/
│       │   ├── views/
│       │   │   ├── HomeView.vue         # eval(), credentials in localStorage, XSS
│       │   │   ├── CustomersView.vue    # XSS via v-html, innerHTML, token in URL
│       │   │   └── TransactionsView.vue # Unmasked card data, hardcoded JWT
│       │   ├── components/
│       │   │   ├── CustomerTable.vue    # Exposed PII without masking
│       │   │   └── TransactionCard.vue  # PAN and CVV visible in cleartext
│       │   ├── router/index.js          # Route configuration
│       │   ├── main.js                  # 🔑 API key in window.__APP_CONFIG__
│       │   └── App.vue                  # Root component
│       ├── package.json                 # Vulnerable npm dependencies (axios, lodash, moment)
│       ├── vite.config.js               # HTTP proxy without TLS
│       ├── index.html                   # HTML entry point
│       └── Dockerfile                   # No multi-stage, root, latest tag
│
├── 📁 infra/                            # Infrastructure as Code (Terraform)
│   ├── main.tf                          # Azure Provider + Resource Group
│   ├── aks.tf                           # AKS: RBAC disabled, public API, no Defender
│   ├── acr.tf                           # ACR: admin enabled, no content trust, Basic SKU
│   ├── storage.tf                       # Storage: public, HTTP, TLS 1.0, sensitive data
│   ├── variables.tf                     # Variables with insecure defaults
│   ├── outputs.tf                       # Outputs with credentials (marked sensitive)
│   └── terraform.tfvars.example         # Variables example
│
├── 📁 k8s/                             # Kubernetes Manifests
│   ├── namespace.yaml                   # No quotas, no network policies
│   ├── api-deployment.yaml              # 🔑 Secrets in env vars, privileged, root
│   ├── api-service.yaml                 # Public LoadBalancer without restrictions
│   ├── web-deployment.yaml              # 🔑 Secrets in env vars, privileged, root
│   ├── web-service.yaml                 # Public LoadBalancer without restrictions
│   └── ingress.yaml                     # No TLS, no WAF, no rate limiting
│
├── 📁 data/                             # Test Data (fictitious)
│   ├── customers.csv                    # 50 records: names, emails, SSN, DNI, credit
│   └── transactions.json               # 30+ transactions: PAN, CVV, addresses
│
├── 📁 docs/                             # Documentation
│   └── demo-guide.md                   # Step-by-step demo guide
│
└── README.md                            # Español
└── README.en.md                         # This file (English)
```

---

## 🔴 Included Vulnerabilities

### 🔍 GitHub Advanced Security (GHAS)

#### CodeQL - Code Scanning

| Vulnerability | File | Severity | CWE |
|--------------|------|----------|-----|
| SQL Injection | `CustomersController.cs` | 🔴 Critical | CWE-89 |
| SQL Injection | `TransactionsController.cs` | 🔴 Critical | CWE-89 |
| Insecure Deserialization (`TypeNameHandling.All`) | `CustomersController.cs`, `TransactionsController.cs` | 🔴 Critical | CWE-502 |
| Path Traversal | `CustomersController.cs`, `TransactionsController.cs` | 🟠 High | CWE-22 |
| XSS via `v-html` | `HomeView.vue`, `CustomersView.vue`, `TransactionsView.vue` | 🟠 High | CWE-79 |
| XSS via `innerHTML` | `CustomersView.vue` | 🟠 High | CWE-79 |
| XSS from URL parameters | `HomeView.vue` | 🟠 High | CWE-79 |
| `eval()` with external input | `HomeView.vue` | 🔴 Critical | CWE-95 |
| Log Injection | `CustomersController.cs`, `TransactionsController.cs` | 🟡 Medium | CWE-117 |
| Information Disclosure (stack traces) | `CustomersController.cs`, `TransactionsController.cs` | 🟡 Medium | CWE-209 |
| CORS misconfiguration (`AllowAnyOrigin`) | `Program.cs` | 🟠 High | CWE-942 |

#### 🔑 Secret Scanning

| Secret | Location |
|--------|----------|
| Azure Storage Connection String | `appsettings.json`, `api-deployment.yaml`, `web-deployment.yaml` |
| SQL Server Credentials (`P@ssw0rd123!`) | `appsettings.json`, `api-deployment.yaml`, `web-deployment.yaml` |
| API Key (`sk-demo-fake-api-key-...`) | `appsettings.json`, `main.js`, `HomeView.vue`, K8s manifests |
| SendGrid API Key | `appsettings.json` |
| Hardcoded JWT Token | `TransactionsView.vue` |
| Credentials in localStorage | `HomeView.vue` (`admin/admin123!`) |
| Session Secret | `web-deployment.yaml` |

#### 📦 Dependabot - Dependency Scanning

| Package | Version | CVE | Severity |
|---------|---------|-----|----------|
| `Newtonsoft.Json` (NuGet) | 12.0.1 | CVE-2021-24112 | 🔴 Critical |
| `System.Data.SqlClient` (NuGet) | 4.8.3 | Multiple CVEs | 🟠 High |
| `System.Text.RegularExpressions` (NuGet) | 4.3.0 | CVE-2018-0786 | 🟡 Medium |
| `axios` (npm) | 0.21.1 | CVE-2021-3749 | 🟠 High |
| `lodash` (npm) | 4.17.20 | CVE-2021-23337 | 🟠 High |
| `moment` (npm) | 2.29.1 | CVE-2022-31129 | 🟡 Medium |

---

### ☁️ Microsoft Defender for Cloud

#### 🔒 CSPM (Cloud Security Posture Management)

| Resource | Misconfiguration | Severity |
|----------|-----------------|----------|
| **AKS** | RBAC disabled | 🔴 Critical |
| **AKS** | API Server accessible from Internet | 🔴 Critical |
| **AKS** | Outdated Kubernetes version (1.27.7) | 🟠 High |
| **AKS** | No Azure Policy or monitoring | 🟡 Medium |
| **ACR** | Admin account enabled | 🟠 High |
| **ACR** | Basic SKU (no vulnerability scanning) | 🟡 Medium |
| **ACR** | Public access enabled | 🟠 High |
| **Storage** | Public blob access (anonymous read) | 🔴 Critical |
| **Storage** | TLS 1.0 allowed | 🟠 High |
| **Storage** | HTTP traffic allowed (no HTTPS enforced) | 🟠 High |
| **Storage** | No soft delete or versioning | 🟡 Medium |

#### 🐳 Defender for Containers

| Finding | Detail |
|---------|--------|
| Vulnerable images | Base images `node:latest`, `dotnet/sdk:latest` without pinning |
| Privileged containers | `privileged: true` on API and Web deployments |
| Root user | `runAsUser: 0` on both deployments |
| Dangerous capabilities | `NET_ADMIN`, `SYS_ADMIN`, `ALL` added |
| Secrets in environment variables | Connection strings and API keys in plain text |
| No resource limits | Pods without CPU/memory limits |
| No health probes | No liveness or readiness probes |

#### 💾 Defender for Storage

| Finding | Detail |
|---------|--------|
| Exposed sensitive data | `sensitive-data` container with blob-level public access |
| PII detected | `customers.csv` with SSN, DNI, emails, phone numbers |
| Financial data | `transactions.json` with full card numbers and CVVs |
| Publicly listable container | `reports` with container-level access (list + read) |

---

### 📊 Vulnerability Mapping

| Vulnerability | Layer | Detection Tool |
|--------------|-------|----------------|
| SQL Injection in API | Source code | CodeQL (GHAS) |
| XSS in Vue frontend | Source code | CodeQL (GHAS) |
| `eval()` with external input | Source code | CodeQL (GHAS) |
| Insecure deserialization | Source code | CodeQL (GHAS) |
| Path Traversal | Source code | CodeQL (GHAS) |
| Hardcoded credentials | Code / Config | Secret Scanning (GHAS) |
| API keys in code | Code / Config | Secret Scanning (GHAS) |
| `Newtonsoft.Json` 12.0.1 | Dependencies | Dependabot (GHAS) |
| `axios` 0.21.1, `lodash` 4.17.20 | Dependencies | Dependabot (GHAS) |
| Public Storage with PII | Infrastructure | Defender for Cloud CSPM |
| AKS without RBAC | Infrastructure | Defender for Cloud CSPM |
| ACR with admin enabled | Infrastructure | Defender for Cloud CSPM |
| TLS 1.0 on Storage | Infrastructure | Defender for Cloud CSPM |
| Vulnerable base images | Containers | Defender for Containers |
| Privileged pods + root | K8s Runtime | Defender for Containers |
| PII in public storage | Data | Defender for Storage |
| Exposed card numbers | Data | Defender for Storage |

---

## 🚀 Prerequisites

| Requirement | Minimum version | Description |
|-------------|----------------|-------------|
| **Azure Subscription** | - | With Owner or Contributor + UAA permissions |
| **Defender for Cloud** | - | Plans enabled: CSPM, Containers, Storage |
| **GitHub Repository** | - | With GHAS enabled (Code Scanning, Secret Scanning, Dependabot) |
| **Terraform** | >= 1.5.0 | To deploy the infrastructure |
| **Azure CLI** | >= 2.50.0 | For authentication and resource management |
| **kubectl** | >= 1.27.0 | For AKS cluster management |
| **.NET SDK** | 6.0 | To build the API |
| **Node.js** | >= 18.x | To build the Vue frontend |
| **Docker** | >= 24.0 | To build container images |

---

## 💻 Local Development with Dev Container

If you don't have **.NET 6** installed on your machine, you can run the entire project inside the development container included in the repository.

### 1️⃣ Open the repository in the container

1. Install Docker Desktop.
2. Install the **Dev Containers** extension in VS Code.
3. Open the repository in VS Code.
4. Run **Dev Containers: Reopen in Container**.

The container automatically installs:

- **.NET SDK 6.0**
- **Node.js 18**
- NuGet and npm project dependencies

### 2️⃣ Start everything with a single command

From a terminal inside the container:

```bash
bash scripts/start-local.sh
```

This script:

- Restores the API
- Installs frontend dependencies
- Starts the API at `http://localhost:5000`
- Starts the frontend at `http://localhost:8080`
- Stops both processes on `Ctrl+C`

### 3️⃣ Start the API

From a terminal inside the container:

```bash
dotnet run --project src/api/SensitiveDataApi.csproj --urls http://0.0.0.0:5000
```

The API will be available at `http://localhost:5000`.

> In `Development` environment, the API automatically uses the `data/` files from the repository so you can test the demo without Azure Storage.

### 4️⃣ Start the frontend

In another terminal inside the container:

```bash
cd src/web
npm run dev -- --host 0.0.0.0 --port 8080
```

The frontend will be available at `http://localhost:8080`.

### 5️⃣ Test the application

- Home: `http://localhost:8080`
- Customers: `http://localhost:8080/customers`
- Transactions: `http://localhost:8080/transactions`

The frontend is pre-configured to proxy `/api` to `http://localhost:5000`.

---

## ⚙️ Deployment

### 1️⃣ Clone the repository

```bash
git clone https://github.com/<your-org>/defender-for-cloud-and-ghas.git
cd defender-for-cloud-and-ghas
```

### 2️⃣ Configure Terraform variables

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
resource_group_name = "rg-security-demo"
location            = "westeurope"
aks_cluster_name    = "aks-security-demo"
acr_name            = "acrsecuritydemo"   # Must be globally unique
storage_name        = "stsecuritydemo"    # Must be globally unique
```

### 3️⃣ Deploy infrastructure

```bash
# Authenticate to Azure
az login

# Initialize Terraform
terraform init

# Review the execution plan
terraform plan -out=tfplan

# Apply the infrastructure
terraform apply tfplan
```

> 📝 Note the Terraform outputs — you'll need them for the following steps.

### 4️⃣ Configure GitHub Secrets

Add the following secrets in your GitHub repository (**Settings → Secrets and variables → Actions**):

| Secret | Value | Source |
|--------|-------|--------|
| `ACR_LOGIN_SERVER` | `<acr-name>.azurecr.io` | Terraform output |
| `ACR_USERNAME` | ACR admin username | Terraform output |
| `ACR_PASSWORD` | ACR admin password | Terraform output |
| `AZURE_CREDENTIALS` | Service Principal JSON | `az ad sp create-for-rbac` |

### 5️⃣ Build and push images

```bash
# Get ACR credentials
ACR_NAME=$(terraform output -raw acr_name)
az acr login --name $ACR_NAME

# Build and push the API
docker build -t $ACR_NAME.azurecr.io/sensitive-data-api:latest ./src/api
docker push $ACR_NAME.azurecr.io/sensitive-data-api:latest

# Build and push the frontend
docker build -t $ACR_NAME.azurecr.io/sensitive-data-web:latest ./src/web
docker push $ACR_NAME.azurecr.io/sensitive-data-web:latest
```

### 6️⃣ Deploy to AKS

```bash
# Get cluster credentials
az aks get-credentials --resource-group rg-security-demo --name aks-security-demo

# Apply manifests
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

### 7️⃣ Verify the deployment

```bash
# View pods
kubectl get pods -n sensitive-app

# View services (get public IPs)
kubectl get svc -n sensitive-app

# View ingress
kubectl get ingress -n sensitive-app
```

---

## 🔍 Demo Guide

For a step-by-step guide on how to perform the demonstration, see:

📄 **[docs/demo-guide.md](docs/demo-guide.md)**

---

## ⚠️ Disclaimer

> **This repository is exclusively for educational and demonstration purposes.**
>
> - ❌ **DO NOT** deploy in production environments
> - ❌ **DO NOT** use the included credentials in real systems
> - ❌ **DO NOT** expose test data on public networks without supervision
> - ✅ **DO** use as learning material about cloud security
> - ✅ **DO** use for controlled demos of Defender for Cloud and GHAS
> - ✅ **DO** destroy all Azure resources after the demo
>
> ```bash
> cd infra && terraform destroy
> ```
>
> **All data, credentials, and keys included are fictitious and created exclusively for this demo.**

---

## 🌐 Follow Me on Social Media

If you liked this project and want to see more content like this, don't forget to subscribe to my YouTube channel and follow me on social media:

[![YouTube Channel Subscribers](https://img.shields.io/youtube/channel/subscribers/UC140iBrEZbOtvxWsJ-Tb0lQ?style=for-the-badge&logo=youtube&logoColor=white&color=red)](https://www.youtube.com/c/GiselaTorres?sub_confirmation=1) [![GitHub followers](https://img.shields.io/github/followers/0GiS0?style=for-the-badge&logo=github&logoColor=white)](https://github.com/0GiS0) [![LinkedIn Follow](https://img.shields.io/badge/LinkedIn-Follow-blue?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/giselatorresbuitrago/) [![X Follow](https://img.shields.io/badge/X-Follow-black?style=for-the-badge&logo=x&logoColor=white)](https://twitter.com/0GiS0)
