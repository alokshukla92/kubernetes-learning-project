#!/bin/bash

echo "🚀 Phase 5 Testing: Advanced Networking & Service Mesh (Istio)"
echo "================================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test endpoint
test_endpoint() {
    local endpoint=$1
    local description=$2
    local expected_status=$3
    
    echo -e "${BLUE}Testing: ${description}${NC}"
    echo -e "Endpoint: ${YELLOW}${endpoint}${NC}"
    
    response=$(curl -s -w "%{http_code}" "${endpoint}")
    http_code="${response: -3}"
    body="${response%???}"
    
    if [ "$http_code" = "$expected_status" ]; then
        echo -e "${GREEN}✅ Status: ${http_code}${NC}"
        echo -e "${GREEN}Response: ${body}${NC}"
    else
        echo -e "${RED}❌ Status: ${http_code} (expected ${expected_status})${NC}"
        echo -e "${RED}Response: ${body}${NC}"
    fi
    echo ""
}

# Check Istio installation
echo -e "${YELLOW}🔍 Checking Istio Installation...${NC}"
if ! kubectl get pods -n istio-system >/dev/null 2>&1; then
    echo -e "${RED}❌ Istio not installed. Please install Istio first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Istio installed${NC}"

# Check Istio pods
echo -e "${BLUE}📋 Istio System Pods:${NC}"
kubectl get pods -n istio-system
echo ""

# Check our namespace pods
echo -e "${BLUE}📋 Kubernetes Learning Namespace Pods:${NC}"
kubectl get pods -n kubernetes-learning
echo ""

# Check Istio sidecar injection
echo -e "${YELLOW}🔍 Checking Istio Sidecar Injection...${NC}"
pods=$(kubectl get pods -n kubernetes-learning -o jsonpath='{.items[*].metadata.name}')
for pod in $pods; do
    containers=$(kubectl get pod $pod -n kubernetes-learning -o jsonpath='{.spec.containers[*].name}')
    if echo "$containers" | grep -q "istio-proxy"; then
        echo -e "${GREEN}✅ ${pod}: Istio sidecar injected${NC}"
    else
        echo -e "${RED}❌ ${pod}: No Istio sidecar${NC}"
    fi
done
echo ""

# Check Gateway and Virtual Service
echo -e "${BLUE}📋 Istio Gateway:${NC}"
kubectl get gateway -n kubernetes-learning
echo ""

echo -e "${BLUE}📋 Istio Virtual Service:${NC}"
kubectl get virtualservice -n kubernetes-learning
echo ""

# Check Istio Ingress Gateway
echo -e "${BLUE}📋 Istio Ingress Gateway Service:${NC}"
kubectl get svc istio-ingressgateway -n istio-system
echo ""

# Test Istio Gateway
echo -e "${YELLOW}🧪 Testing Istio Gateway Access...${NC}"
ingress_port=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')

if [ -z "$ingress_port" ]; then
    ingress_port=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.spec.ports[0].nodePort}')
fi

if [ -n "$ingress_port" ]; then
    echo -e "${GREEN}✅ Ingress Gateway Port: ${ingress_port}${NC}"
    
    # Test basic access
    test_endpoint "http://127.0.0.1:${ingress_port}/" "Istio Gateway - Root path" "200"
    
    # Test API path
    test_endpoint "http://127.0.0.1:${ingress_port}/api" "Istio Gateway - API path" "200"
    
else
    echo -e "${RED}❌ Could not determine Ingress Gateway port${NC}"
fi

# Check Istio metrics
echo -e "${YELLOW}📊 Istio Metrics (if available):${NC}"
if kubectl get pods -n kubernetes-learning -l app=fastapi | grep -q Running; then
    echo -e "${GREEN}✅ FastAPI pod is running${NC}"
    
    # Try to get Istio proxy stats
    pod_name=$(kubectl get pods -n kubernetes-learning -l app=fastapi -o jsonpath='{.items[0].metadata.name}')
    echo -e "${BLUE}📈 Istio Proxy Stats for ${pod_name}:${NC}"
    kubectl exec -n kubernetes-learning $pod_name -c istio-proxy -- curl -s http://localhost:15000/stats | head -10 2>/dev/null || echo "Stats not accessible"
else
    echo -e "${RED}❌ FastAPI pod not running${NC}"
fi
echo ""

# Show Istio configuration
echo -e "${BLUE}📋 Current Istio Configuration:${NC}"
echo -e "${YELLOW}Gateway:${NC}"
kubectl get gateway kubernetes-learning-gateway -n kubernetes-learning -o yaml | grep -A 10 "spec:"
echo ""

echo -e "${YELLOW}Virtual Service:${NC}"
kubectl get virtualservice fastapi-virtualservice -n kubernetes-learning -o yaml | grep -A 15 "spec:"
echo ""

# Show what we've learned
echo -e "${GREEN}🎉 Phase 5 Testing Complete!${NC}"
echo ""
echo -e "${BLUE}📚 What we've learned about Service Mesh:${NC}"
echo "✅ Istio provides automatic sidecar injection"
echo "✅ mTLS certificates are automatically managed"
echo "✅ Service discovery through Istio control plane"
echo "✅ Traffic routing via Gateway and Virtual Service"
echo "✅ Observability and metrics collection"
echo "✅ Security policies and access control"
echo ""
echo -e "${YELLOW}🚀 Next: Advanced Traffic Management & Observability${NC}" 