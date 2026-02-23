# Actualización Automática de Secret ECR para Kubernetes

Solución para actualizar automáticamente el secret de docker-registry de AWS ECR cada 10 horas en un cluster de Kubernetes ubicado fuera de la infraestructura de AWS.

## 🚀 Inicio Rápido

### 1. Configurar el Namespace

Edita `kustomization.yaml` y cambia el namespace:

```yaml
namespace: tenant-blue-identity  # Cambia esto por tu namespace
```

### 2. Configurar Credenciales AWS

Edita `aws-credentials-secret.yaml` con tus credenciales:

```yaml
stringData:
  AWS_ACCESS_KEY_ID: "TU_ACCESS_KEY"
  AWS_SECRET_ACCESS_KEY: "TU_SECRET_KEY"
  AWS_DEFAULT_REGION: "eu-west-1"
```

### 3. Desplegar

```bash
cd k8s-ecr-secret-refresh
./deploy.sh
```

**¡Listo!** El CronJob comenzará a actualizar el secret automáticamente cada 10 horas.

---

## 📋 Verificación

### Ver el CronJob:
```bash
kubectl get cronjob -n tenant--identity
```

### Ver los Jobs ejecutados:
```bash
kubectl get jobs -n tenant-blue-identity
```

### Ver el secret creado:
```bash
kubectl get secret eudistack-stg-ecr-secret -n tenant-blue-identity
```

---

## 🧪 Prueba Manual

Para probar el CronJob inmediatamente sin esperar 10 horas:

```bash
# Crear un Job manual para probar
kubectl create job --from=cronjob/ecr-secret-refresh prueba-manual -n tenant-blue-identity

# Ver los logs en tiempo real
kubectl logs -f job/prueba-manual -n tenant-blue-identity

# Verificar que el secret se creó correctamente
kubectl describe secret eudistack-stg-ecr-secret -n tenant-blue-identity
```

---

## 📦 Usar el Secret en tus Deployments

Añade `imagePullSecrets` a tus Deployments para usar las imágenes de ECR:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mi-aplicacion
  namespace: tenant-blue-identity
spec:
  template:
    spec:
      # Referencia al secret de ECR
      imagePullSecrets:
      - name: eudistack-stg-ecr-secret
      containers:
      - name: mi-contenedor
        image: 147108726325.dkr.ecr.eu-west-1.amazonaws.com/mi-imagen:latest
```

---

## ⚙️ Personalización Avanzada

### Cambiar el Registro de ECR o Nombre del Secret

Descomenta y edita la sección `patches` en `kustomization.yaml`:

```yaml
patches:
  - patch: |-
      - op: replace
        path: /spec/jobTemplate/spec/template/spec/containers/0/env/0/value
        value: "999999999.dkr.ecr.us-east-1.amazonaws.com"
    target:
      kind: CronJob
      name: ecr-secret-refresh
```

### Cambiar la Frecuencia de Actualización

Edita `cronjob.yaml` y modifica el schedule:

```yaml
schedule: "0 */8 * * *"  # Cada 8 horas
schedule: "0 0 * * *"    # Cada día a medianoche
schedule: "*/30 * * * *" # Cada 30 minutos (para pruebas)
```

---

## 🔧 Solución de Problemas

### Ver logs de un Job fallido:
```bash
kubectl get jobs -n tenant-blue-identity
kubectl logs job/ecr-secret-refresh-<id> -n tenant-blue-identity
```

### Eliminar el CronJob:
```bash
kubectl delete cronjob ecr-secret-refresh -n tenant-blue-identity
```

### Volver a desplegar:
```bash
kubectl apply -k .
```

### Verificar permisos RBAC:
```bash
kubectl get serviceaccount ecr-secret-refresh-sa -n tenant-blue-identity
kubectl get role ecr-secret-refresh-role -n tenant-blue-identity
kubectl get rolebinding ecr-secret-refresh-rolebinding -n tenant-blue-identity
```

---

## 📚 Documentación Adicional

- **[README.md](README.md)** - Documentación completa en inglés
- **[DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md)** - Guía de despliegue avanzada (multi-namespace, overlays)
- **[kustomization-example.yaml](kustomization-example.yaml)** - Ejemplo completo de personalización

---

## ❓ Preguntas Frecuentes

### ¿Por qué cada 10 horas?
Los tokens de ECR expiran cada 12 horas. Actualizar cada 10 horas asegura que siempre tengas un token válido.

### ¿Funciona fuera de AWS?
Sí, está diseñado específicamente para clusters de Kubernetes fuera de AWS que necesitan acceder a registros ECR.

### ¿Puedo usar esto en múltiples namespaces?
Sí, simplemente despliega el CronJob en cada namespace que lo necesite, o consulta [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) para configuraciones multi-namespace.

### ¿Es seguro almacenar credenciales en un Secret?
Los Secrets de Kubernetes están codificados en base64 por defecto. Para mayor seguridad, considera usar:
- AWS IAM Roles for Service Accounts (IRSA) si tu cluster lo soporta
- External Secrets Operator
- Sealed Secrets
- Vault

---

## 🔒 Seguridad

**⚠️ IMPORTANTE:** No subas `aws-credentials-secret.yaml` con credenciales reales al control de versiones.

El archivo `.gitignore` ya está configurado para ignorar este archivo.

---

## 📝 Componentes

| Archivo | Descripción |
|---------|-------------|
| `kustomization.yaml` | Configuración central (namespace) |
| `aws-credentials-secret.yaml` | Credenciales de AWS |
| `rbac.yaml` | ServiceAccount, Role y RoleBinding |
| `cronjob.yaml` | CronJob que actualiza el secret |
| `deploy.sh` | Script de despliegue automatizado |

---

## ✅ ¿Cómo Funciona?

1. El CronJob se ejecuta cada 10 horas
2. Usa las credenciales de AWS para obtener un token de login de ECR
3. Crea o actualiza el secret `eudistack-stg-ecr-secret`
4. Los Pods pueden usar este secret con `imagePullSecrets`
5. El namespace es completamente parametrizable vía Kustomize

---

**¿Necesitas ayuda?** Consulta [README.md](README.md) para la documentación completa o [DEPLOYMENT-GUIDE.md](DEPLOYMENT-GUIDE.md) para escenarios avanzados.