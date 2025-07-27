# Phase 2: Configuration & Secrets Management

## 🎯 Learning Objectives

In this phase, you'll learn how to:
- Use **ConfigMaps** to store non-sensitive configuration
- Use **Secrets** to store sensitive data (passwords, API keys)
- Inject configuration into your applications
- Secure MongoDB with authentication
- Verify configuration injection

## 📚 Key Concepts

### ConfigMap
- Stores non-sensitive configuration data
- Can be mounted as files or environment variables
- Perfect for application settings, URLs, ports, etc.

### Secret
- Stores sensitive data (passwords, tokens, keys)
- Base64 encoded by default
- Can be mounted as files or environment variables
- More secure than ConfigMaps

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   FastAPI Pod   │    │   MongoDB Pod   │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Environment │ │    │ │ Environment │ │
│ │ Variables   │ │    │ │ Variables   │ │
│ └─────────────┘ │    │ └─────────────┘ │
│        │        │    │        │        │
│        ▼        │    │        ▼        │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ ConfigMap   │ │    │ │   Secret    │ │
│ │ (non-sens)  │ │    │ │ (sensitive) │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
```

## 🚀 Deployment

### Quick Start
```bash
# Deploy everything
./deploy-phase2.sh

# Verify the setup
./verify-phase2.sh
```

### Manual Deployment
```bash
# 1. Build Docker image
docker build -t fastapi-mongo-app:latest .

# 2. Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# 3. Apply Secret
kubectl apply -f k8s/mongo-secret.yaml

# 4. Deploy MongoDB with auth
kubectl apply -f k8s/mongo-deployment.yaml

# 5. Deploy FastAPI
kubectl apply -f k8s/fastapi-deployment.yaml
```

## 🔍 Verification Commands

### Check Resources
```bash
# View all resources
kubectl get all

# Check ConfigMap
kubectl get configmap fastapi-config -o yaml

# Check Secret (base64 encoded)
kubectl get secret mongo-secret -o yaml

# View pod logs
kubectl logs deployment/fastapi
```

### Test Application
```bash
# Get service URL
minikube service fastapi-service --url

# Test endpoints
curl $(minikube service fastapi-service --url)/
curl $(minikube service fastapi-service --url)/health
curl -X POST "$(minikube service fastapi-service --url)/items/?name=test&description=test"
curl $(minikube service fastapi-service --url)/items/
```

### Verify Environment Variables
```bash
# Get pod name
FASTAPI_POD=$(kubectl get pods -l app=fastapi -o jsonpath='{.items[0].metadata.name}')

# Check ConfigMap values
kubectl exec $FASTAPI_POD -- env | grep -E "(MONGO_HOST|MONGO_PORT|MONGO_DB)"

# Check Secret values (base64 encoded)
kubectl exec $FASTAPI_POD -- env | grep -E "(MONGO_USER|MONGO_PASS)"
```

## 🔐 Security Notes

### Secret Management
- Secrets are base64 encoded but not encrypted
- In production, consider using:
  - Kubernetes External Secrets Operator
  - HashiCorp Vault
  - Cloud provider secret management (AWS Secrets Manager, GCP Secret Manager)

### Best Practices
- Never commit secrets to version control
- Use RBAC to control access to secrets
- Rotate secrets regularly
- Use namespaces to isolate secrets

## 🧪 Testing Scenarios

### 1. Configuration Changes
```bash
# Update ConfigMap
kubectl patch configmap fastapi-config --patch '{"data":{"MONGO_DB":"newdb"}}'

# Restart FastAPI to pick up changes
kubectl rollout restart deployment/fastapi
```

### 2. Secret Updates
```bash
# Update Secret (base64 encode first)
echo -n "newpassword" | base64
kubectl patch secret mongo-secret --patch '{"data":{"MONGO_PASS":"bmV3cGFzc3dvcmQ="}}'

# Restart both services
kubectl rollout restart deployment/mongo
kubectl rollout restart deployment/fastapi
```

### 3. Pod Shell Access
```bash
# Access FastAPI pod
kubectl exec -it deployment/fastapi -- /bin/bash

# Access MongoDB pod
kubectl exec -it deployment/mongo -- mongosh -u admin -p password123
```

## 📖 What You've Learned

✅ **ConfigMap Usage**: Storing non-sensitive configuration  
✅ **Secret Usage**: Storing sensitive data securely  
✅ **Environment Variable Injection**: How K8s injects config into pods  
✅ **MongoDB Authentication**: Setting up secure database access  
✅ **Application Configuration**: Making apps configurable via K8s  
✅ **Verification Techniques**: How to verify configuration is working  

## 🔄 Next Steps

You're ready for **Phase 3: Persistent Volumes + StatefulSet** where you'll:
- Make MongoDB data persistent
- Learn about PVC, PV, and StorageClass
- Migrate MongoDB to StatefulSet
- Ensure data survives pod restarts

## 🛠️ Troubleshooting

### Common Issues

1. **MongoDB Connection Failed**
   ```bash
   kubectl logs deployment/fastapi
   kubectl logs deployment/mongo
   ```

2. **Secret Not Found**
   ```bash
   kubectl get secret
   kubectl describe secret mongo-secret
   ```

3. **ConfigMap Not Applied**
   ```bash
   kubectl get configmap
   kubectl describe configmap fastapi-config
   ```

4. **Pod Not Starting**
   ```bash
   kubectl describe pod <pod-name>
   kubectl get events --sort-by='.lastTimestamp'
   ``` 