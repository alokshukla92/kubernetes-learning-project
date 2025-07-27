#!/bin/bash

echo "🔍 Phase 2 Verification: Configuration & Secrets"
echo "================================================="

# Get service URL
SERVICE_URL=$(minikube service fastapi-service --url)
echo "🌐 Service URL: $SERVICE_URL"

echo ""
echo "📊 Checking pod status..."
kubectl get pods

echo ""
echo "🔧 Checking ConfigMap..."
kubectl get configmap fastapi-config -o yaml

echo ""
echo "🔐 Checking Secret (values are base64 encoded)..."
kubectl get secret mongo-secret -o yaml

echo ""
echo "🧪 Testing FastAPI endpoints..."

echo "1. Testing root endpoint:"
curl -s "$SERVICE_URL/" | jq '.'

echo ""
echo "2. Testing health endpoint:"
curl -s "$SERVICE_URL/health" | jq '.'

echo ""
echo "3. Creating a test item:"
curl -s -X POST "$SERVICE_URL/items/?name=test-item&description=This is a test item" | jq '.'

echo ""
echo "4. Retrieving all items:"
curl -s "$SERVICE_URL/items/" | jq '.'

echo ""
echo "🔍 Checking pod logs for MongoDB connection:"
kubectl logs deployment/fastapi --tail=10

echo ""
echo "🔐 Verifying environment variables in FastAPI pod:"
FASTAPI_POD=$(kubectl get pods -l app=fastapi -o jsonpath='{.items[0].metadata.name}')
echo "FastAPI Pod: $FASTAPI_POD"

echo "ConfigMap values:"
kubectl exec $FASTAPI_POD -- env | grep -E "(MONGO_HOST|MONGO_PORT|MONGO_DB)"

echo "Secret values (should be base64 encoded):"
kubectl exec $FASTAPI_POD -- env | grep -E "(MONGO_USER|MONGO_PASS)"

echo ""
echo "✅ Phase 2 verification complete!" 