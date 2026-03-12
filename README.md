# 🛡️ Defender for Cloud & GitHub Advanced Security - Demo

> Demo de integración entre **Microsoft Defender for Cloud** y **GitHub Advanced Security (GHAS)** para detección de vulnerabilidades end-to-end: desde el código fuente hasta la infraestructura en Azure.

⚠️ **ADVERTENCIA**: Este repositorio contiene código y configuraciones **intencionalmente vulnerables** con fines educativos y de demostración. **NO utilizar en producción.**

---

## 🎯 Objetivo

Demostrar cómo la combinación de **GitHub Advanced Security (GHAS)** y **Microsoft Defender for Cloud** proporciona una visión completa de seguridad a lo largo de todo el ciclo de vida del software:

- **Shift-Left (GHAS)**: Detectar vulnerabilidades en el código fuente, dependencias y secretos _antes_ de llegar a producción.
- **Runtime & CSPM (Defender for Cloud)**: Identificar misconfiguraciones en la infraestructura cloud, vulnerabilidades en contenedores y exposición de datos sensibles _en tiempo de ejecución_.
- **Visión unificada**: Correlacionar hallazgos de ambas herramientas para priorizar remediación basada en riesgo real.

---

## 🏗️ Arquitectura

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
│  │  (público,   │ │  (admin   │  │   (público, HTTP,      │   │
│  │  sin RBAC)   │ │  enabled) │  │    datos sensibles)    │   │
│  └──────────────┘ └───────────┘  └─────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Componentes

| Componente | Tecnología | Propósito |
|------------|-----------|-----------|
| **API Backend** | .NET 6 (C#) | API REST con vulnerabilidades de código (SQL Injection, XSS, deserialización insegura) |
| **Web Frontend** | Vue 3 + Vite | SPA con vulnerabilidades client-side (XSS, `eval()`, credenciales hardcodeadas) |
| **Infraestructura** | Terraform | Recursos Azure intencionalmente misconfigurardos (AKS, ACR, Storage) |
| **Kubernetes** | YAML manifests | Deployments inseguros (privileged, root, sin network policies) |
| **Datos de prueba** | CSV / JSON | Datos ficticios sensibles (PII, tarjetas de crédito, SSN) |

---

## 📂 Estructura del Repositorio

```
defender-for-cloud-and-ghas/
├── 📁 src/
│   ├── 📁 api/                          # API Backend (.NET 6)
│   │   ├── Controllers/
│   │   │   ├── CustomersController.cs   # SQL Injection, Path Traversal, deserialización insegura
│   │   │   └── TransactionsController.cs # API key hardcodeada, SQL Injection, IDOR
│   │   ├── Models/
│   │   │   ├── Customer.cs              # Modelo con datos sensibles (SSN, DNI)
│   │   │   └── Transaction.cs           # Modelo con datos de tarjetas (PAN, CVV)
│   │   ├── Program.cs                   # CORS permisivo, sin HTTPS, sin auth middleware
│   │   ├── appsettings.json             # 🔑 Connection strings, API keys, credenciales DB
│   │   ├── SensitiveDataApi.csproj      # Dependencias NuGet vulnerables
│   │   └── Dockerfile                   # Sin multi-stage, root, latest tag
│   │
│   └── 📁 web/                          # Frontend (Vue 3 + Vite)
│       ├── src/
│       │   ├── views/
│       │   │   ├── HomeView.vue         # eval(), credenciales en localStorage, XSS
│       │   │   ├── CustomersView.vue    # XSS via v-html, innerHTML, token en URL
│       │   │   └── TransactionsView.vue # Datos de tarjeta sin enmascarar, JWT hardcodeado
│       │   ├── components/
│       │   │   ├── CustomerTable.vue    # PII expuesta sin máscara
│       │   │   └── TransactionCard.vue  # PAN y CVV visibles en claro
│       │   ├── router/index.js          # Configuración de rutas
│       │   ├── main.js                  # 🔑 API key en window.__APP_CONFIG__
│       │   └── App.vue                  # Componente raíz
│       ├── package.json                 # Dependencias npm vulnerables (axios, lodash, moment)
│       ├── vite.config.js               # Proxy HTTP sin TLS
│       ├── index.html                   # Entry point HTML
│       └── Dockerfile                   # Sin multi-stage, root, latest tag
│
├── 📁 infra/                            # Infraestructura como Código (Terraform)
│   ├── main.tf                          # Provider Azure + Resource Group
│   ├── aks.tf                           # AKS: RBAC deshabilitado, API pública, sin Defender
│   ├── acr.tf                           # ACR: admin habilitado, sin content trust, SKU básico
│   ├── storage.tf                       # Storage: público, HTTP, TLS 1.0, datos sensibles
│   ├── variables.tf                     # Variables con defaults inseguros
│   ├── outputs.tf                       # Outputs con credenciales (marcadas sensitive)
│   └── terraform.tfvars.example         # Ejemplo de variables
│
├── 📁 k8s/                             # Manifiestos Kubernetes
│   ├── namespace.yaml                   # Sin quotas, sin network policies
│   ├── api-deployment.yaml              # 🔑 Secrets en env vars, privileged, root
│   ├── api-service.yaml                 # LoadBalancer público sin restricciones
│   ├── web-deployment.yaml              # 🔑 Secrets en env vars, privileged, root
│   ├── web-service.yaml                 # LoadBalancer público sin restricciones
│   └── ingress.yaml                     # Sin TLS, sin WAF, sin rate limiting
│
├── 📁 data/                             # Datos de prueba (ficticios)
│   ├── customers.csv                    # 50 registros: nombres, emails, SSN, DNI, crédito
│   └── transactions.json               # 30+ transacciones: PAN, CVV, direcciones
│
├── 📁 docs/                             # Documentación
│   └── demo-guide.md                   # Guía paso a paso para la demo
│
└── README.md                            # Este archivo
```

---

## 🔴 Vulnerabilidades Incluidas

### 🔍 GitHub Advanced Security (GHAS)

#### CodeQL - Code Scanning

| Vulnerabilidad | Archivo | Severidad | CWE |
|---------------|---------|-----------|-----|
| SQL Injection | `CustomersController.cs` | 🔴 Crítica | CWE-89 |
| SQL Injection | `TransactionsController.cs` | 🔴 Crítica | CWE-89 |
| Insecure Deserialization (`TypeNameHandling.All`) | `CustomersController.cs`, `TransactionsController.cs` | 🔴 Crítica | CWE-502 |
| Path Traversal | `CustomersController.cs`, `TransactionsController.cs` | 🟠 Alta | CWE-22 |
| XSS via `v-html` | `HomeView.vue`, `CustomersView.vue`, `TransactionsView.vue` | 🟠 Alta | CWE-79 |
| XSS via `innerHTML` | `CustomersView.vue` | 🟠 Alta | CWE-79 |
| XSS desde parámetros URL | `HomeView.vue` | 🟠 Alta | CWE-79 |
| `eval()` con input externo | `HomeView.vue` | 🔴 Crítica | CWE-95 |
| Log Injection | `CustomersController.cs`, `TransactionsController.cs` | 🟡 Media | CWE-117 |
| Information Disclosure (stack traces) | `CustomersController.cs`, `TransactionsController.cs` | 🟡 Media | CWE-209 |
| CORS misconfiguration (`AllowAnyOrigin`) | `Program.cs` | 🟠 Alta | CWE-942 |

#### 🔑 Secret Scanning

| Secreto | Ubicación |
|---------|-----------|
| Azure Storage Connection String | `appsettings.json`, `api-deployment.yaml`, `web-deployment.yaml` |
| SQL Server Credentials (`P@ssw0rd123!`) | `appsettings.json`, `api-deployment.yaml`, `web-deployment.yaml` |
| API Key (`sk-demo-fake-api-key-...`) | `appsettings.json`, `main.js`, `HomeView.vue`, K8s manifests |
| SendGrid API Key | `appsettings.json` |
| JWT Token hardcodeado | `TransactionsView.vue` |
| Credenciales en localStorage | `HomeView.vue` (`admin/admin123!`) |
| Session Secret | `web-deployment.yaml` |

#### 📦 Dependabot - Dependency Scanning

| Paquete | Versión | CVE | Severidad |
|---------|---------|-----|-----------|
| `Newtonsoft.Json` (NuGet) | 12.0.1 | CVE-2021-24112 | 🔴 Crítica |
| `System.Data.SqlClient` (NuGet) | 4.8.3 | Múltiples CVEs | 🟠 Alta |
| `System.Text.RegularExpressions` (NuGet) | 4.3.0 | CVE-2018-0786 | 🟡 Media |
| `axios` (npm) | 0.21.1 | CVE-2021-3749 | 🟠 Alta |
| `lodash` (npm) | 4.17.20 | CVE-2021-23337 | 🟠 Alta |
| `moment` (npm) | 2.29.1 | CVE-2022-31129 | 🟡 Media |

---

### ☁️ Microsoft Defender for Cloud

#### 🔒 CSPM (Cloud Security Posture Management)

| Recurso | Misconfiguración | Severidad |
|---------|-----------------|-----------|
| **AKS** | RBAC deshabilitado | 🔴 Crítica |
| **AKS** | API Server accesible desde Internet | 🔴 Crítica |
| **AKS** | Versión de Kubernetes obsoleta (1.27.7) | 🟠 Alta |
| **AKS** | Sin Azure Policy ni monitorización | 🟡 Media |
| **ACR** | Admin account habilitado | 🟠 Alta |
| **ACR** | SKU Basic (sin vulnerability scanning) | 🟡 Media |
| **ACR** | Acceso público habilitado | 🟠 Alta |
| **Storage** | Acceso público a blobs (anonymous read) | 🔴 Crítica |
| **Storage** | TLS 1.0 permitido | 🟠 Alta |
| **Storage** | Tráfico HTTP permitido (sin HTTPS obligatorio) | 🟠 Alta |
| **Storage** | Sin soft delete ni versionado | 🟡 Media |

#### 🐳 Defender for Containers

| Finding | Detalle |
|---------|---------|
| Imágenes con vulnerabilidades | Base images `node:latest`, `dotnet/sdk:latest` sin pinning |
| Contenedores privilegiados | `privileged: true` en API y Web deployments |
| Root user | `runAsUser: 0` en ambos deployments |
| Capabilities peligrosas | `NET_ADMIN`, `SYS_ADMIN`, `ALL` añadidas |
| Secrets en variables de entorno | Connection strings y API keys en plain text |
| Sin resource limits | Pods sin límites de CPU/memoria |
| Sin health probes | Sin liveness ni readiness probes |

#### 💾 Defender for Storage

| Finding | Detalle |
|---------|---------|
| Datos sensibles expuestos | Contenedor `sensitive-data` con acceso público blob-level |
| PII detectada | `customers.csv` con SSN, DNI, emails, teléfonos |
| Datos financieros | `transactions.json` con números de tarjeta y CVVs completos |
| Contenedor público listable | `reports` con acceso container-level (list + read) |

---

### 📊 Mapeo de Vulnerabilidades

| Vulnerabilidad | Capa | Herramienta de Detección |
|---------------|------|--------------------------|
| SQL Injection en API | Código fuente | CodeQL (GHAS) |
| XSS en frontend Vue | Código fuente | CodeQL (GHAS) |
| `eval()` con input externo | Código fuente | CodeQL (GHAS) |
| Deserialización insegura | Código fuente | CodeQL (GHAS) |
| Path Traversal | Código fuente | CodeQL (GHAS) |
| Credenciales hardcodeadas | Código / Config | Secret Scanning (GHAS) |
| API keys en código | Código / Config | Secret Scanning (GHAS) |
| `Newtonsoft.Json` 12.0.1 | Dependencias | Dependabot (GHAS) |
| `axios` 0.21.1, `lodash` 4.17.20 | Dependencias | Dependabot (GHAS) |
| Storage público con PII | Infraestructura | Defender for Cloud CSPM |
| AKS sin RBAC | Infraestructura | Defender for Cloud CSPM |
| ACR con admin habilitado | Infraestructura | Defender for Cloud CSPM |
| TLS 1.0 en Storage | Infraestructura | Defender for Cloud CSPM |
| Imágenes base vulnerables | Contenedores | Defender for Containers |
| Pods privilegiados + root | Runtime K8s | Defender for Containers |
| PII en storage público | Datos | Defender for Storage |
| Números de tarjeta expuestos | Datos | Defender for Storage |

---

## 🚀 Requisitos Previos

| Requisito | Versión mínima | Descripción |
|-----------|---------------|-------------|
| **Azure Subscription** | - | Con permisos de Owner o Contributor + UAA |
| **Defender for Cloud** | - | Planes habilitados: CSPM, Containers, Storage |
| **GitHub Repository** | - | Con GHAS habilitado (Code Scanning, Secret Scanning, Dependabot) |
| **Terraform** | >= 1.5.0 | Para desplegar la infraestructura |
| **Azure CLI** | >= 2.50.0 | Para autenticación y gestión de recursos |
| **kubectl** | >= 1.27.0 | Para gestión del cluster AKS |
| **.NET SDK** | 6.0 | Para compilar la API |
| **Node.js** | >= 18.x | Para compilar el frontend Vue |
| **Docker** | >= 24.0 | Para construir imágenes de contenedor |

---

## ⚙️ Despliegue

### 1️⃣ Clonar el repositorio

```bash
git clone https://github.com/<tu-org>/defender-for-cloud-and-ghas.git
cd defender-for-cloud-and-ghas
```

### 2️⃣ Configurar variables de Terraform

```bash
cd infra
cp terraform.tfvars.example terraform.tfvars
```

Edita `terraform.tfvars` con tus valores:

```hcl
resource_group_name = "rg-security-demo"
location            = "westeurope"
aks_cluster_name    = "aks-security-demo"
acr_name            = "acrsecuritydemo"   # Debe ser único globalmente
storage_name        = "stsecuritydemo"    # Debe ser único globalmente
```

### 3️⃣ Desplegar infraestructura

```bash
# Autenticarse en Azure
az login

# Inicializar Terraform
terraform init

# Revisar el plan de ejecución
terraform plan -out=tfplan

# Aplicar la infraestructura
terraform apply tfplan
```

> 📝 Anota los outputs de Terraform, los necesitarás para los siguientes pasos.

### 4️⃣ Configurar GitHub Secrets

Añade los siguientes secrets en tu repositorio de GitHub (**Settings → Secrets and variables → Actions**):

| Secret | Valor | Origen |
|--------|-------|--------|
| `ACR_LOGIN_SERVER` | `<acr-name>.azurecr.io` | Output de Terraform |
| `ACR_USERNAME` | Admin username del ACR | Output de Terraform |
| `ACR_PASSWORD` | Admin password del ACR | Output de Terraform |
| `AZURE_CREDENTIALS` | JSON del Service Principal | `az ad sp create-for-rbac` |

### 5️⃣ Build y push de imágenes

```bash
# Obtener credenciales del ACR
ACR_NAME=$(terraform output -raw acr_name)
az acr login --name $ACR_NAME

# Build y push de la API
docker build -t $ACR_NAME.azurecr.io/sensitive-data-api:latest ./src/api
docker push $ACR_NAME.azurecr.io/sensitive-data-api:latest

# Build y push del frontend
docker build -t $ACR_NAME.azurecr.io/sensitive-data-web:latest ./src/web
docker push $ACR_NAME.azurecr.io/sensitive-data-web:latest
```

### 6️⃣ Desplegar en AKS

```bash
# Obtener credenciales del cluster
az aks get-credentials --resource-group rg-security-demo --name aks-security-demo

# Aplicar manifiestos
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/
```

### 7️⃣ Verificar el despliegue

```bash
# Ver pods
kubectl get pods -n sensitive-app

# Ver servicios (obtener IPs públicas)
kubectl get svc -n sensitive-app

# Ver ingress
kubectl get ingress -n sensitive-app
```

---

## 🔍 Guía de Demo

Para una guía paso a paso de cómo realizar la demostración, consulta:

📄 **[docs/demo-guide.md](docs/demo-guide.md)**

---

## ⚠️ Disclaimer

> **Este repositorio es exclusivamente para fines educativos y de demostración.**
>
> - ❌ **NO** desplegar en entornos de producción
> - ❌ **NO** utilizar las credenciales incluidas en sistemas reales
> - ❌ **NO** exponer los datos de prueba en redes públicas sin supervisión
> - ✅ **SÍ** usar como material de aprendizaje sobre seguridad cloud
> - ✅ **SÍ** usar para demos controladas de Defender for Cloud y GHAS
> - ✅ **SÍ** destruir todos los recursos Azure al finalizar la demo
>
> ```bash
> cd infra && terraform destroy
> ```
>
> **Todos los datos, credenciales y claves incluidas son ficticias y creadas exclusivamente para esta demo.**
