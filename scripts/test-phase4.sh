#!/bin/bash

echo "🚀 Phase 4 Testing: Ingress Controllers & Advanced Networking"
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
    
    response=$(curl -s -w "%{http_code}" -H "Host: fastapi.local" "http://127.0.0.1${endpoint}")
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

# Check if minikube tunnel is running
echo -e "${YELLOW}🔍 Checking Ingress setup...${NC}"
if ! kubectl get ingress fastapi-ingress >/dev/null 2>&1; then
    echo -e "${RED}❌ Ingress not found. Please run: kubectl apply -f k8s/ingress.yaml${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Ingress found${NC}"

# Check if tunnel is accessible
if ! curl -s -H "Host: fastapi.local" http://127.0.0.1/ >/dev/null 2>&1; then
    echo -e "${RED}❌ Ingress not accessible. Please ensure minikube tunnel is running${NC}"
    echo -e "${YELLOW}Run: minikube tunnel${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Ingress accessible${NC}"
echo ""

# Test FastAPI endpoints
echo -e "${BLUE}🧪 Testing FastAPI Endpoints via Ingress:${NC}"
echo ""

test_endpoint "/" "Root endpoint" "200"
test_endpoint "/health" "Health check" "200"
test_endpoint "/items/" "Get all items" "200"

# Test creating a new item
echo -e "${BLUE}➕ Testing Item Creation:${NC}"
echo -e "Creating item via Ingress..."
response=$(curl -s -X POST -H "Host: fastapi.local" "http://127.0.0.1/items/?name=phase4-test&description=Created%20via%20Phase%204%20testing")
echo -e "${GREEN}✅ Created: ${response}${NC}"
echo ""

# Test admin panel
echo -e "${BLUE}🖥️ Testing Admin Panel:${NC}"
if kubectl get service admin-service >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Admin service found${NC}"
    echo -e "${YELLOW}Admin panel available at: http://127.0.0.1:8080/${NC}"
    echo -e "${YELLOW}(Run: kubectl port-forward service/admin-service 8080:80)${NC}"
else
    echo -e "${RED}❌ Admin service not found${NC}"
fi
echo ""

# Show current items
echo -e "${BLUE}📊 Current Items in Database:${NC}"
curl -s -H "Host: fastapi.local" http://127.0.0.1/items/ | jq '.' 2>/dev/null || curl -s -H "Host: fastapi.local" http://127.0.0.1/items/
echo ""

# Show Ingress status
echo -e "${BLUE}📋 Ingress Status:${NC}"
kubectl get ingress
echo ""

# Show services
echo -e "${BLUE}🔗 Services:${NC}"
kubectl get services
echo ""

echo -e "${GREEN}🎉 Phase 4 Testing Complete!${NC}"
echo ""
echo -e "${BLUE}📚 What we've learned:${NC}"
echo "✅ Ingress controllers provide clean URLs and domain names"
echo "✅ Path-based routing allows multiple services on one domain"
echo "✅ External access without random NodePorts"
echo "✅ Load balancing and SSL capabilities"
echo "✅ Rate limiting and advanced annotations"
echo ""
echo -e "${YELLOW}🚀 Next: Phase 5 - Advanced Networking & Service Mesh${NC}" 