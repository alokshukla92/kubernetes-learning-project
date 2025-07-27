#!/bin/bash

echo "🚀 Phase 5 Load Testing: Health Checks + Autoscaling"
echo "===================================================="
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

# Check if hey is installed
check_hey() {
    if ! command -v hey &> /dev/null; then
        echo -e "${YELLOW}📦 Installing hey load testing tool...${NC}"
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS
            brew install hey
        else
            # Linux
            wget -O hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64
            chmod +x hey
            sudo mv hey /usr/local/bin/
        fi
    fi
    echo -e "${GREEN}✅ hey load testing tool available${NC}"
}

# Check current deployment status
echo -e "${YELLOW}🔍 Checking Current Deployment Status...${NC}"
echo -e "${BLUE}📋 Pods:${NC}"
kubectl get pods -l app=fastapi-hpa
echo ""

echo -e "${BLUE}📋 HPA Status:${NC}"
kubectl get hpa
echo ""

echo -e "${BLUE}📋 Service:${NC}"
kubectl get svc fastapi-hpa-service
echo ""

# Get service port
SERVICE_PORT=$(kubectl get svc fastapi-hpa-service -o jsonpath='{.spec.ports[0].nodePort}')
if [ -z "$SERVICE_PORT" ]; then
    echo -e "${RED}❌ Could not get service port${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Service accessible on port: ${SERVICE_PORT}${NC}"
echo ""

# Test health endpoints
echo -e "${YELLOW}🧪 Testing Health Endpoints...${NC}"
test_endpoint "http://127.0.0.1:${SERVICE_PORT}/health" "Health Check" "200"
test_endpoint "http://127.0.0.1:${SERVICE_PORT}/ready" "Readiness Check" "200"
test_endpoint "http://127.0.0.1:${SERVICE_PORT}/live" "Liveness Check" "200"
test_endpoint "http://127.0.0.1:${SERVICE_PORT}/metrics" "Metrics Endpoint" "200"

# Install hey if not available
check_hey

# Show initial resource usage
echo -e "${YELLOW}📊 Initial Resource Usage:${NC}"
kubectl top pods -l app=fastapi-hpa 2>/dev/null || echo "Metrics server not available"
echo ""

# Load testing scenarios
echo -e "${YELLOW}🔥 Starting Load Testing...${NC}"
echo ""

# Scenario 1: Light load
echo -e "${BLUE}📈 Scenario 1: Light Load (10 requests/sec for 30 seconds)${NC}"
hey -z 30s -q 10 -c 5 http://127.0.0.1:${SERVICE_PORT}/health
echo ""

# Check HPA after light load
echo -e "${BLUE}📋 HPA Status after light load:${NC}"
kubectl get hpa
echo ""

# Scenario 2: Medium load
echo -e "${BLUE}📈 Scenario 2: Medium Load (50 requests/sec for 60 seconds)${NC}"
hey -z 60s -q 50 -c 10 http://127.0.0.1:${SERVICE_PORT}/health
echo ""

# Check HPA after medium load
echo -e "${BLUE}📋 HPA Status after medium load:${NC}"
kubectl get hpa
echo ""

# Scenario 3: Heavy load
echo -e "${BLUE}📈 Scenario 3: Heavy Load (100 requests/sec for 90 seconds)${NC}"
hey -z 90s -q 100 -c 20 http://127.0.0.1:${SERVICE_PORT}/health
echo ""

# Final status check
echo -e "${YELLOW}📊 Final Status Check:${NC}"
echo -e "${BLUE}📋 Pods:${NC}"
kubectl get pods -l app=fastapi-hpa
echo ""

echo -e "${BLUE}📋 HPA Status:${NC}"
kubectl get hpa
echo ""

echo -e "${BLUE}📋 Resource Usage:${NC}"
kubectl top pods -l app=fastapi-hpa 2>/dev/null || echo "Metrics server not available"
echo ""

# Show HPA events
echo -e "${BLUE}📋 HPA Events:${NC}"
kubectl describe hpa fastapi-hpa | grep -A 10 "Events:"
echo ""

# Show what we've learned
echo -e "${GREEN}🎉 Phase 5 Load Testing Complete!${NC}"
echo ""
echo -e "${BLUE}📚 What we've learned:${NC}"
echo "✅ Health checks ensure pod readiness and liveness"
echo "✅ HPA automatically scales based on CPU/Memory usage"
echo "✅ Load testing helps validate scaling behavior"
echo "✅ Resource limits prevent resource exhaustion"
echo "✅ Monitoring helps track scaling performance"
echo ""
echo -e "${YELLOW}🚀 Next: Advanced Monitoring & Observability${NC}" 