# 🎬 Guía de Demo: Defender for Cloud & GitHub Advanced Security

> Guía paso a paso para realizar una demostración de ~20 minutos mostrando la detección de vulnerabilidades end-to-end con **GitHub Advanced Security** y **Microsoft Defender for Cloud**.

---

## 📋 Preparación

Antes de comenzar la demo, asegúrate de tener listo:

### ✅ Checklist

- [ ] **Infraestructura desplegada** en Azure (AKS, ACR, Storage Account) via Terraform
- [ ] **Imágenes Docker** construidas y subidas al ACR (`sensitive-data-api`, `sensitive-data-web`)
- [ ] **Pods corriendo** en AKS (`kubectl get pods -n sensitive-app`)
- [ ] **GHAS habilitado** en el repositorio de GitHub (Code Scanning, Secret Scanning, Dependabot)
- [ ] **CodeQL workflow** configurado y ejecutado al menos una vez
- [ ] **Defender for Cloud** con planes activos: CSPM, Containers, Storage
- [ ] **Datos sensibles** subidos al Storage Account (customers.csv, transactions.json)
- [ ] **Pestañas del navegador** abiertas:
  - GitHub → pestaña Security del repositorio
  - Azure Portal → Defender for Cloud
  - Azure Portal → Resource Group de la demo

### 🖥️ Setup del navegador

Recomendamos tener estas pestañas preparadas:

| # | Pestaña | URL |
|---|---------|-----|
| 1 | GitHub - Security Overview | `github.com/<org>/<repo>/security` |
| 2 | GitHub - Code Scanning | `github.com/<org>/<repo>/security/code-scanning` |
| 3 | GitHub - Secret Scanning | `github.com/<org>/<repo>/security/secret-scanning` |
| 4 | GitHub - Dependabot | `github.com/<org>/<repo>/security/dependabot` |
| 5 | Azure - Defender for Cloud | Portal → Microsoft Defender for Cloud |
| 6 | Azure - Resource Group | Portal → Resource Groups → `rg-security-demo` |

---

## 📖 Parte 1: GitHub Advanced Security (Shift-Left)

> ⏱️ Duración estimada: **8-10 minutos**

### 1.1 🔬 Habilitar GHAS en el repositorio

> 💡 Si GHAS ya está habilitado, puedes saltar este paso y mencionarlo brevemente.

1. Ve a **Settings → Code security and analysis**
2. Habilita:
   - ✅ **Dependency graph**
   - ✅ **Dependabot alerts**
   - ✅ **Dependabot security updates**
   - ✅ **Code scanning** (con CodeQL)
   - ✅ **Secret scanning**
   - ✅ **Push protection**

### 1.2 🔍 Configurar CodeQL

1. Ve a **Actions → New workflow → CodeQL Analysis**
2. Selecciona los lenguajes:
   - `csharp` (para la API .NET)
   - `javascript` (para el frontend Vue)
3. Ejecuta el workflow manualmente o espera al siguiente push

> 💡 **Tip para la demo**: Ten el workflow ya ejecutado. Muestra brevemente la configuración del YAML y luego pasa directamente a los resultados.

### 1.3 🚨 Mostrar alertas de Code Scanning

Navega a **Security → Code scanning alerts** y muestra las vulnerabilidades detectadas:

#### Vulnerabilidades críticas a destacar:

| # | Vulnerabilidad | Archivo | Qué mostrar |
|---|---------------|---------|-------------|
| 1 | **SQL Injection** | `CustomersController.cs` | Concatenación de strings en query SQL: `"SELECT * FROM Customers WHERE FirstName LIKE '%" + query + "%'"`. Explicar que un atacante podría inyectar `'; DROP TABLE Customers; --` |
| 2 | **Insecure Deserialization** | `TransactionsController.cs` | `TypeNameHandling.All` en Newtonsoft.Json permite ejecución remota de código (RCE) |
| 3 | **XSS via v-html** | `CustomersView.vue` | Input del usuario renderizado como HTML sin sanitizar. `v-html="searchResultMessage"` con contenido controlado por el usuario |
| 4 | **eval() con input externo** | `HomeView.vue` | `eval('(' + configStr + ')')` permite inyección de código JavaScript arbitrario |
| 5 | **Path Traversal** | `CustomersController.cs` | Endpoint `/export/{filename}` sin validación. Un atacante puede usar `../../../etc/passwd` |

> 🎯 **Punto clave**: _"CodeQL no solo encuentra las vulnerabilidades, sino que muestra el flujo de datos completo desde el origen (source) hasta el punto vulnerable (sink), facilitando la comprensión y remediación."_

### 1.4 🔑 Mostrar alertas de Secret Scanning

Navega a **Security → Secret scanning alerts** y muestra:

| # | Secreto | Ubicación | Impacto |
|---|---------|-----------|---------|
| 1 | Azure Storage Connection String | `appsettings.json` | Acceso completo a la cuenta de almacenamiento |
| 2 | SQL Server Password | `appsettings.json` | Acceso a la base de datos de clientes |
| 3 | API Key (`sk-demo-fake-...`) | `main.js`, `HomeView.vue` | Bypass de autenticación de la API |
| 4 | SendGrid API Key | `appsettings.json` | Envío de emails en nombre de la organización |
| 5 | Credenciales en K8s manifests | `api-deployment.yaml` | Acceso a todos los servicios backend |

> 🎯 **Punto clave**: _"Secret Scanning detecta credenciales antes de que lleguen a producción. Con Push Protection habilitado, el commit ni siquiera se permite si contiene un secreto reconocido."_

**Demo adicional**: Muestra cómo funciona **Push Protection**:
1. Intenta hacer push de un archivo con una credencial real
2. GitHub bloquea el push y muestra el tipo de secreto detectado
3. Explica las opciones: revocar, marcar como falso positivo, o justificar

### 1.5 📦 Mostrar alertas de Dependabot

Navega a **Security → Dependabot alerts** y muestra:

#### Dependencias .NET (NuGet)

| Paquete | Versión actual | CVE | Fix disponible |
|---------|---------------|-----|---------------|
| `Newtonsoft.Json` | 12.0.1 | CVE-2021-24112 (Crítica) | ✅ Actualizar a 13.0.3+ |
| `System.Data.SqlClient` | 4.8.3 | Múltiples CVEs | ✅ Migrar a `Microsoft.Data.SqlClient` |
| `System.Text.RegularExpressions` | 4.3.0 | CVE-2018-0786 | ✅ Actualizar a 4.3.1+ |

#### Dependencias JavaScript (npm)

| Paquete | Versión actual | CVE | Fix disponible |
|---------|---------------|-----|---------------|
| `axios` | 0.21.1 | CVE-2021-3749 (Alta) | ✅ Actualizar a 1.6.0+ |
| `lodash` | 4.17.20 | CVE-2021-23337 (Alta) | ✅ Actualizar a 4.17.21+ |
| `moment` | 2.29.1 | CVE-2022-31129 (Media) | ⚠️ Considerar migrar a `dayjs` |

> 🎯 **Punto clave**: _"Dependabot no solo alerta, sino que puede generar Pull Requests automáticos con la versión segura. Esto reduce drásticamente el tiempo de remediación."_

### 1.6 📊 Priorización y flujo de remediación

Muestra la **Security Overview** del repositorio:

1. **Vista general**: Número de alertas por severidad (Crítica, Alta, Media, Baja)
2. **Filtros**: Filtrar por herramienta (CodeQL, Secret Scanning, Dependabot)
3. **Workflow de remediación**:
   - Abrir una alerta → Ver el código afectado → Crear issue/PR
   - Mostrar cómo se cierra automáticamente una alerta cuando se mergea el fix
4. **Autofix con Copilot** (si disponible): Mostrar sugerencias de fix generadas por IA

---

## ☁️ Parte 2: Defender for Cloud (Runtime & CSPM)

> ⏱️ Duración estimada: **8-10 minutos**

### 2.1 📊 Dashboard de Defender for Cloud

1. Abre **Microsoft Defender for Cloud** en el portal de Azure
2. Muestra el **Secure Score** general
3. Muestra las **Recommendations** ordenadas por impacto

> 🎯 **Punto clave**: _"Defender for Cloud evalúa continuamente la postura de seguridad de todos tus recursos Azure. El Secure Score te da una métrica clara de tu nivel de seguridad."_

### 2.2 🔒 CSPM: Findings de infraestructura

Navega a **Recommendations** y filtra por el resource group de la demo:

#### Azure Kubernetes Service (AKS)

| Finding | Severidad | Recomendación |
|---------|-----------|--------------|
| Role-Based Access Control should be enabled | 🔴 Alta | Habilitar RBAC en configuración del cluster |
| Kubernetes Services should be upgraded to a non-vulnerable version | 🟠 Media | Actualizar a versión 1.29+ |
| Authorized IP ranges should be defined on AKS | 🔴 Alta | Configurar `authorized_ip_ranges` |
| Azure Policy for Kubernetes should be installed | 🟡 Baja | Habilitar Azure Policy Add-on |

#### Azure Container Registry (ACR)

| Finding | Severidad | Recomendación |
|---------|-----------|--------------|
| Container registries should not allow unrestricted network access | 🟠 Media | Configurar private endpoints |
| Admin account should be disabled | 🟠 Media | Usar Azure RBAC + managed identities |

#### Storage Account

| Finding | Severidad | Recomendación |
|---------|-----------|--------------|
| Storage accounts should restrict network access | 🔴 Alta | Configurar firewall y VNet rules |
| Secure transfer to storage accounts should be enabled | 🔴 Alta | Forzar HTTPS (`enable_https_traffic_only = true`) |
| Storage account minimum TLS version should be set to TLS 1.2 | 🟠 Media | Configurar `min_tls_version = "TLS1_2"` |
| Storage accounts should prevent public blob access | 🔴 Alta | Deshabilitar acceso público a blobs |
| Soft delete should be enabled for blobs | 🟡 Baja | Configurar blob soft delete |

> 🎯 **Punto clave**: _"Cada recomendación incluye los pasos exactos para remediarla, el impacto en el Secure Score, y la opción de automatizar el fix con Azure Policy."_

### 2.3 🐳 Defender for Containers: Vulnerabilidades en imágenes

1. Navega a **Defender for Cloud → Workload protections → Containers**
2. Muestra las **vulnerabilidades de imagen** detectadas en el ACR:
   - Paquetes del OS con CVEs conocidos
   - Dependencias de la aplicación vulnerables
   - Imágenes sin pinning de versión

3. Muestra los **findings de runtime** en el cluster AKS:

| Finding | Detalle | Riesgo |
|---------|---------|--------|
| Container running as root | `runAsUser: 0` en ambos deployments | Escalación de privilegios al host |
| Privileged container | `privileged: true` | Acceso completo al host node |
| Dangerous capabilities | `SYS_ADMIN`, `NET_ADMIN`, `ALL` | Control total de la red y sistema |
| Sensitive host path mounted | Potencial acceso a filesystem del host | Data exfiltration |
| Pod without resource limits | Sin límites de CPU/memoria | Denial of Service |

> 🎯 **Punto clave**: _"Defender for Containers no solo escanea imágenes en el registro, sino que también monitoriza el runtime de Kubernetes, detectando configuraciones peligrosas y comportamientos anómalos."_

### 2.4 💾 Defender for Storage: Datos sensibles

1. Navega a **Defender for Cloud → Workload protections → Storage**
2. Muestra las alertas de **Sensitive Data Discovery**:
   - ⚠️ **PII detectada** en `sensitive-data/customers.csv`:
     - Nombres completos, emails, teléfonos
     - Números de identificación (SSN, DNI)
     - Fechas de nacimiento
     - Puntuaciones de crédito
   - ⚠️ **Datos financieros** en `sensitive-data/transactions.json`:
     - Números de tarjeta de crédito completos (PAN)
     - CVVs
     - Direcciones de facturación

3. Muestra que el **contenedor es público**:
   - Cualquier persona con la URL puede acceder a estos datos
   - No se requiere autenticación

> 🎯 **Punto clave**: _"Defender for Storage puede detectar automáticamente datos sensibles (PII, datos financieros, datos de salud) en tus cuentas de almacenamiento, alertándote cuando están expuestos de forma insegura."_

### 2.5 🕸️ Attack Path Analysis

1. Navega a **Defender for Cloud → Attack path analysis**
2. Muestra un attack path que conecte múltiples findings:

```
Internet → AKS (API pública, sin RBAC)
         → Pod privilegiado (root + SYS_ADMIN)
         → Acceso al Storage Account (connection string en env vars)
         → Datos sensibles expuestos (PII + datos financieros)
```

**Narrativa del attack path**:
> _"Un atacante puede acceder al API Server de AKS desde Internet (sin restricciones IP). Como RBAC está deshabilitado, puede listar todos los pods y leer las variables de entorno. Ahí encuentra la connection string del Storage Account. Con esa credencial, accede al contenedor público donde hay datos sensibles de clientes y transacciones financieras."_

> 🎯 **Punto clave**: _"Attack path analysis conecta vulnerabilidades individuales para mostrar escenarios de ataque reales. Esto es clave para priorizar: no todas las vulnerabilidades tienen el mismo riesgo."_

---

## 🔗 Parte 3: Integración GHAS + Defender for Cloud

> ⏱️ Duración estimada: **3-5 minutos**

### 3.1 🌐 Visión unificada

Muestra cómo ambas herramientas se complementan:

```
┌─────────────────────────────────────────────────────────────────┐
│                                                                  │
│   GHAS (Shift-Left)              Defender (Runtime)             │
│                                                                  │
│   ┌─────────────────┐           ┌─────────────────┐            │
│   │ SQL Injection    │──────────▶│ Pod privilegiado │            │
│   │ en API (código)  │           │ ejecutando API   │            │
│   └─────────────────┘           └────────┬────────┘            │
│                                          │                      │
│   ┌─────────────────┐           ┌────────▼────────┐            │
│   │ Connection string│──────────▶│ Storage público  │            │
│   │ hardcodeada      │           │ con PII expuesta │            │
│   └─────────────────┘           └─────────────────┘            │
│                                                                  │
│   ┌─────────────────┐           ┌─────────────────┐            │
│   │ Dependencias     │──────────▶│ Imagen vulnerable │            │
│   │ vulnerables      │           │ en ACR + AKS     │            │
│   └─────────────────┘           └─────────────────┘            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 🔄 Correlación código → runtime

Explica cómo cada hallazgo de GHAS tiene un impacto medible en runtime:

| Hallazgo GHAS (Código) | Impacto en Runtime (Defender) | Riesgo combinado |
|------------------------|-------------------------------|-----------------|
| SQL Injection en `CustomersController.cs` | Pod ejecuta como root + privileged | 🔴 **Crítico**: SQL Injection + escalación a host |
| Connection string en `appsettings.json` | Storage Account público con PII | 🔴 **Crítico**: Credencial válida → datos sensibles expuestos |
| `Newtonsoft.Json` 12.0.1 (RCE) | Imagen desplegada en AKS sin escaneo | 🔴 **Crítico**: RCE + privileged container = control total |
| XSS en frontend | Servicio expuesto a Internet via LoadBalancer | 🟠 **Alto**: XSS accesible desde Internet |
| API key hardcodeada | API accesible sin restricciones IP | 🟠 **Alto**: Bypass de autenticación |

### 3.3 🎯 Priorización basada en contexto

Demuestra que la priorización cambia cuando se combinan contextos:

> _"Una SQL Injection es severa por sí sola. Pero cuando esa SQL Injection está en un servicio que corre como root en un pod privilegiado, con acceso a un Storage Account público que contiene datos financieros reales... se convierte en un riesgo **crítico** que debe remediarse inmediatamente."_

**Criterios de priorización**:
1. ⚡ **Exposed to Internet** + código vulnerable = prioridad máxima
2. 🔐 **Datos sensibles accesibles** desde el componente vulnerable = prioridad alta
3. 👤 **Privilegios elevados** (root, privileged, SYS_ADMIN) = amplifica el impacto
4. 🔗 **Connection strings válidas** en código = camino directo a datos

---

## 🎤 Narrativa Sugerida (~20 minutos)

### Introducción (2 min)

> _"Hoy vamos a ver cómo proteger una aplicación desde el código hasta la nube, usando dos herramientas que se complementan perfectamente: GitHub Advanced Security para el shift-left, y Microsoft Defender for Cloud para la protección en runtime._
>
> _Tenemos una aplicación ficticia de gestión de datos de clientes y transacciones financieras. Intencionalmente tiene vulnerabilidades en todas las capas para demostrar las capacidades de detección."_

### Parte 1: GHAS - Shift-Left (8 min)

> _"Empecemos por donde debería empezar la seguridad: en el código fuente._
>
> **Code Scanning con CodeQL**: Aquí vemos que CodeQL ha detectado SQL Injection en nuestro controlador de clientes. Miren cómo muestra el flujo completo: el input del usuario entra por el parámetro `query`, no se sanitiza, y termina directamente en la consulta SQL. Un atacante podría extraer toda la base de datos._
>
> **Secret Scanning**: Además, tenemos credenciales en el código. Aquí hay una connection string de Azure Storage con su access key, y aquí una contraseña de base de datos SQL. Con Push Protection habilitado, estos commits ni siquiera habrían llegado al repositorio._
>
> **Dependabot**: Y por último, nuestras dependencias. Newtonsoft.Json 12.0.1 tiene una vulnerabilidad crítica de deserialización remota. Dependabot ya generó un PR automático para actualizarlo."_

### Parte 2: Defender for Cloud - Runtime (8 min)

> _"Ahora veamos qué pasa cuando este código llega a producción._
>
> **CSPM**: Defender for Cloud nos muestra que nuestro AKS no tiene RBAC habilitado, que el API Server es público, y que nuestro Storage Account permite tráfico HTTP sin cifrar. Cada recomendación tiene los pasos exactos para remediarla._
>
> **Containers**: Las imágenes Docker que subimos al ACR tienen vulnerabilidades conocidas. Además, nuestros pods están corriendo como root con modo privilegiado. Esto significa que si un atacante explota la SQL Injection, puede escalar privilegios hasta controlar el nodo completo._
>
> **Storage**: Y aquí viene lo más preocupante. Defender ha detectado que tenemos datos sensibles – números de tarjeta de crédito, SSN, DNI – en un contenedor de Storage que es público. Cualquiera con la URL puede descargarlo._
>
> **Attack Path**: Miren este attack path: desde Internet → AKS público → pod privilegiado → connection string en variables de entorno → Storage con datos sensibles. Esto conecta todo."_

### Parte 3: La visión completa (2 min)

> _"La verdadera potencia está en combinar ambas herramientas. La SQL Injection que CodeQL encontró en el código, ahora la vemos desplegada en un pod privilegiado con acceso a datos sensibles. Una vulnerabilidad de severidad alta en el código se convierte en un riesgo **crítico** en producción porque el contexto amplifica el impacto._
>
> _Con GHAS detectamos las vulnerabilidades antes de que lleguen a producción. Con Defender for Cloud las detectamos si ya están desplegadas y entendemos su impacto real. Juntas, nos dan la visibilidad completa para priorizar y remediar lo que realmente importa."_

---

## 🧹 Limpieza

> ⚠️ **Importante**: Destruye todos los recursos Azure al finalizar la demo para evitar costes innecesarios.

### 1️⃣ Eliminar deployments de Kubernetes

```bash
kubectl delete namespace sensitive-app
```

### 2️⃣ Destruir infraestructura con Terraform

```bash
cd infra
terraform destroy -auto-approve
```

### 3️⃣ Verificar eliminación

```bash
# Verificar que no quedan recursos
az resource list --resource-group rg-security-demo --output table

# Si el resource group persiste, eliminarlo manualmente
az group delete --name rg-security-demo --yes --no-wait
```

### 4️⃣ Limpiar configuración local

```bash
# Eliminar contexto de kubectl
kubectl config delete-context aks-security-demo

# Eliminar estado de Terraform
rm -rf infra/.terraform infra/terraform.tfstate*
```

> 💡 **Tip**: Si usas este repo frecuentemente para demos, considera automatizar el despliegue y limpieza con un script `deploy.sh` / `cleanup.sh`.
