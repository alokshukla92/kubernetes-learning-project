#!/bin/bash

echo "🚀 Deploying Phase 2: Configuration & Secrets"
echo "=============================================="

# Build the Docker image
echo "📦 Building Docker image..."
docker build -t fastapi-mongo-app:latest .

# Apply Kubernetes configurations
echo "🔧 Applying ConfigMap..."
kubectl apply -f k8s/configmap.yaml

echo "🔐 Applying Secret..."
kubectl apply -f k8s/mongo-secret.yaml

echo "🗄️ Deploying MongoDB with authentication..."
kubectl apply -f k8s/mongo-deployment.yaml

echo "⏳ Waiting for MongoDB to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/mongo

echo "🚀 Deploying FastAPI with ConfigMap and Secret..."
kubectl apply -f k8s/fastapi-deployment.yaml

echo "⏳ Waiting for FastAPI to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/fastapi

echo "✅ Phase 2 deployment complete!"
echo ""
echo "🔍 Verification commands:"
echo "kubectl get pods"
echo "kubectl get configmap"
echo "kubectl get secret"
echo "kubectl logs deployment/fastapi"
echo "minikube service fastapi-service"
echo ""
echo "🧪 Test the application:"
echo "curl $(minikube service fastapi-service --url)/"
echo "curl $(minikube service fastapi-service --url)/health" 