# 🚀 Deployment Guide

This guide will walk you through setting up and deploying the Kubernetes Learning Project.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software
- **Docker Desktop**: [Download here](https://www.docker.com/products/docker-desktop)
- **Minikube**: [Installation guide](https://minikube.sigs.k8s.io/docs/start/)
- **kubectl**: [Installation guide](https://kubernetes.io/docs/tasks/tools/)
- **Python 3.9+**: [Download here](https://www.python.org/downloads/)

### Verify Installation
```bash
# Check Docker
docker --version

# Check Minikube
minikube version

# Check kubectl
kubectl version --client

# Check Python
python3 --version
```

## 🏃‍♂️ Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/kubernetes-learning-project.git
cd kubernetes-learning-project
```

### 2. Start Minikube
```bash
minikube start
```

### 3. Build and Deploy
```bash
# Build Docker image
docker build -t fastapi-mongo-app:latest .

# Load image to Minikube
minikube image load fastapi-mongo-app:latest

# Deploy to Kubernetes
./scripts/deploy-phase2.sh
```

### 4. Verify Deployment
```bash
./scripts/verify-phase2.sh
```

## 🔧 Detailed Setup

### Step 1: Environment Setup

1. **Start Docker Desktop**
   - Open Docker Desktop application
   - Wait for it to start completely

2. **Start Minikube**
   ```bash
   minikube start
   ```

3. **Verify Minikube Status**
   ```bash
   minikube status
   ```

### Step 2: Application Setup

1. **Navigate to Project Directory**
   ```bash
   cd kubernetes-learning-project
   ```

2. **Build Docker Image**
   ```bash
   docker build -t fastapi-mongo-app:latest .
   ```

3. **Load Image to Minikube**
   ```bash
   minikube image load fastapi-mongo-app:latest
   ```

### Step 3: Kubernetes Deployment

1. **Deploy ConfigMap and Secret**
   ```bash
   kubectl apply -f k8s/configmap.yaml
   kubectl apply -f k8s/mongo-secret.yaml
   ```

2. **Deploy MongoDB**
   ```bash
   kubectl apply -f k8s/mongo-deployment.yaml
   ```

3. **Deploy FastAPI Application**
   ```bash
   kubectl apply -f k8s/fastapi-deployment.yaml
   ```

4. **Wait for Pods to be Ready**
   ```bash
   kubectl wait --for=condition=ready pod -l app=mongo --timeout=300s
   kubectl wait --for=condition=ready pod -l app=fastapi --timeout=300s
   ```

### Step 4: Verification

1. **Check Pod Status**
   ```bash
   kubectl get pods
   ```

2. **Check Services**
   ```bash
   kubectl get services
   ```

3. **Test FastAPI Application**
   ```bash
   # Get FastAPI pod name
   FASTAPI_POD=$(kubectl get pods -l app=fastapi -o jsonpath='{.items[0].metadata.name}')
   
   # Test root endpoint
   kubectl exec $FASTAPI_POD -- curl -s http://localhost:8000/
   
   # Test health endpoint
   kubectl exec $FASTAPI_POD -- curl -s http://localhost:8000/health
   ```

4. **Test MongoDB Connection**
   ```bash
   # Get MongoDB pod name
   MONGO_POD=$(kubectl get pods -l app=mongo -o jsonpath='{.items[0].metadata.name}')
   
   # Test MongoDB connection
   kubectl exec $MONGO_POD -- mongosh --eval "db.runCommand('ping')"
   ```

## 🧪 Testing the Application

### API Endpoints

1. **Root Endpoint**
   ```bash
   kubectl exec $FASTAPI_POD -- curl -s http://localhost:8000/
   ```
   Expected response:
   ```json
   {
     "message": "FastAPI is working!",
     "mongo_connected": true,
     "mongo_host": "mongo-service",
     "mongo_port": 27017,
     "mongo_db": "testdb",
     "config_source": "ConfigMap and Secret (Phase 2)"
   }
   ```

2. **Health Check**
   ```bash
   kubectl exec $FASTAPI_POD -- curl -s http://localhost:8000/health
   ```
   Expected response:
   ```json
   {
     "status": "healthy",
     "mongo_connected": true
   }
   ```

3. **Create Item**
   ```bash
   kubectl exec $FASTAPI_POD -- curl -s -X POST "http://localhost:8000/items/?name=test-item&description=This is a test item"
   ```

4. **Get All Items**
   ```bash
   kubectl exec $FASTAPI_POD -- curl -s http://localhost:8000/items/
   ```

### External Access (Optional)

If you want to access the application from outside the cluster:

```bash
# Get the NodePort
kubectl get service fastapi-service

# Access via NodePort (replace 32483 with your actual port)
curl http://127.0.0.1:32483/
```

## 🔍 Troubleshooting

### Common Issues

1. **Docker Not Running**
   ```bash
   # Start Docker Desktop
   open -a Docker
   ```

2. **Minikube Not Running**
   ```bash
   # Start Minikube
   minikube start
   ```

3. **Image Pull Issues**
   ```bash
   # Rebuild and reload image
   docker build -t fastapi-mongo-app:latest .
   minikube image load fastapi-mongo-app:latest
   kubectl rollout restart deployment/fastapi
   ```

4. **Pod Not Starting**
   ```bash
   # Check pod logs
   kubectl logs <pod-name>
   
   # Describe pod for more details
   kubectl describe pod <pod-name>
   ```

5. **MongoDB Connection Issues**
   ```bash
   # Check MongoDB logs
   kubectl logs <mongo-pod>
   
   # Test MongoDB directly
   kubectl exec <mongo-pod> -- mongosh --eval "db.runCommand('ping')"
   ```

### Useful Commands

```bash
# Get all resources
kubectl get all

# Get specific resources
kubectl get pods
kubectl get services
kubectl get deployments
kubectl get configmap
kubectl get secret

# Describe resources
kubectl describe pod <pod-name>
kubectl describe service <service-name>
kubectl describe deployment <deployment-name>

# View logs
kubectl logs <pod-name>
kubectl logs -f <pod-name>  # Follow logs

# Execute commands in pods
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec <pod-name> -- <command>

# Port forward (for debugging)
kubectl port-forward <pod-name> 8000:8000
```

## 🧹 Cleanup

To clean up the deployment:

```bash
# Delete all resources
kubectl delete -f k8s/

# Or delete individually
kubectl delete deployment fastapi
kubectl delete deployment mongo
kubectl delete service fastapi-service
kubectl delete service mongo-service
kubectl delete configmap fastapi-config
kubectl delete secret mongo-secret

# Stop Minikube
minikube stop

# Delete Minikube cluster (optional)
minikube delete
```

## 📚 Next Steps

After successfully deploying Phase 2:

1. **Phase 3**: Implement Persistent Volumes and StatefulSets
2. **Phase 4**: Add Ingress controllers and advanced features
3. **Production**: Add monitoring, logging, and security features

## 🤝 Getting Help

If you encounter issues:

1. Check the troubleshooting section above
2. Review the logs using `kubectl logs`
3. Check the GitHub issues page
4. Create a new issue with detailed information

---

**Happy Deploying! 🚀** 