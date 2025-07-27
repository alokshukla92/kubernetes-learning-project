#!/bin/bash

echo "🚀 Visual Load Testing with Real-time Monitoring"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if service is accessible
check_service() {
    local service_name=$1
    local port=$2
    local description=$3
    
    echo -e "${BLUE}🔍 Checking ${description}...${NC}"
    if curl -s http://127.0.0.1:${port} >/dev/null 2>&1; then
        echo -e "${GREEN}✅ ${description} accessible at http://127.0.0.1:${port}${NC}"
        return 0
    else
        echo -e "${RED}❌ ${description} not accessible${NC}"
        return 1
    fi
}

# Function to run load test with monitoring
run_load_test() {
    local duration=$1
    local qps=$2
    local concurrency=$3
    local endpoint=$4
    local description=$5
    
    echo -e "${YELLOW}🔥 Starting ${description}${NC}"
    echo -e "Duration: ${duration}, QPS: ${qps}, Concurrency: ${concurrency}"
    echo -e "Endpoint: ${endpoint}"
    echo ""
    
    # Run hey load test
    hey -z ${duration} -q ${qps} -c ${concurrency} ${endpoint} &
    HEY_PID=$!
    
    # Monitor during load test
    echo -e "${BLUE}📊 Monitoring during load test...${NC}"
    for i in {1..10}; do
        echo -e "${YELLOW}--- Monitoring Round ${i} ---${NC}"
        
        # Check HPA status
        echo -e "${BLUE}📋 HPA Status:${NC}"
        kubectl get hpa fastapi-hpa
        
        # Check pod count
        echo -e "${BLUE}📋 Pod Count:${NC}"
        kubectl get pods -l app=fastapi-hpa --no-headers | wc -l
        
        # Check resource usage (if metrics server available)
        echo -e "${BLUE}📊 Resource Usage:${NC}"
        kubectl top pods -l app=fastapi-hpa 2>/dev/null || echo "Metrics server not available"
        
        # Check Prometheus metrics
        if check_service "prometheus" "30090" "Prometheus" >/dev/null; then
            echo -e "${BLUE}📈 Prometheus Metrics:${NC}"
            curl -s http://127.0.0.1:30090/api/v1/query?query=http_requests_total | jq '.data.result | length' 2>/dev/null || echo "No metrics data yet"
        fi
        
        echo ""
        sleep 5
    done
    
    # Wait for hey to finish
    wait $HEY_PID
    echo -e "${GREEN}✅ Load test completed${NC}"
    echo ""
}

# Check prerequisites
echo -e "${YELLOW}🔍 Checking Prerequisites...${NC}"

# Check if hey is installed
if ! command -v hey &> /dev/null; then
    echo -e "${RED}❌ hey not installed. Please install it first.${NC}"
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}📦 Installing jq...${NC}"
    brew install jq
fi

echo -e "${GREEN}✅ Prerequisites check passed${NC}"
echo ""

# Deploy monitoring if not already deployed
echo -e "${YELLOW}📦 Deploying Monitoring Stack...${NC}"
kubectl apply -f k8s/monitoring-setup.yaml
echo ""

# Wait for monitoring to be ready
echo -e "${YELLOW}⏳ Waiting for monitoring to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=prometheus --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana --timeout=120s
echo -e "${GREEN}✅ Monitoring ready${NC}"
echo ""

# Build and deploy updated FastAPI
echo -e "${YELLOW}🔨 Building and Deploying Updated FastAPI...${NC}"
docker build -t fastapi-mongo-app:latest .
minikube image load fastapi-mongo-app:latest
kubectl apply -f k8s/hpa-fastapi-deployment.yaml
echo ""

# Wait for FastAPI to be ready
echo -e "${YELLOW}⏳ Waiting for FastAPI to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app=fastapi-hpa --timeout=120s
echo -e "${GREEN}✅ FastAPI ready${NC}"
echo ""

# Get service port
SERVICE_PORT=$(kubectl get svc fastapi-hpa-service -o jsonpath='{.spec.ports[0].nodePort}')
if [ -z "$SERVICE_PORT" ]; then
    echo -e "${RED}❌ Could not get service port${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Service accessible on port: ${SERVICE_PORT}${NC}"
echo ""

# Check all services
echo -e "${YELLOW}🔍 Checking Service Accessibility...${NC}"
check_service "fastapi" "${SERVICE_PORT}" "FastAPI Application"
check_service "prometheus" "30090" "Prometheus"
check_service "grafana" "30300" "Grafana"
echo ""

# Show monitoring URLs
echo -e "${BLUE}📊 Monitoring URLs:${NC}"
echo -e "${YELLOW}Prometheus:${NC} http://127.0.0.1:30090"
echo -e "${YELLOW}Grafana:${NC} http://127.0.0.1:30300 (admin/admin123)"
echo -e "${YELLOW}FastAPI Metrics:${NC} http://127.0.0.1:${SERVICE_PORT}/metrics"
echo ""

# Test endpoints
echo -e "${YELLOW}🧪 Testing Endpoints...${NC}"
curl -s http://127.0.0.1:${SERVICE_PORT}/health | jq .
curl -s http://127.0.0.1:${SERVICE_PORT}/metrics | head -10
echo ""

# Load testing scenarios
echo -e "${YELLOW}🔥 Starting Load Testing Scenarios...${NC}"
echo ""

# Scenario 1: Light load
run_load_test "30s" "10" "5" "http://127.0.0.1:${SERVICE_PORT}/health" "Light Load Test"

# Scenario 2: Medium load
run_load_test "60s" "50" "10" "http://127.0.0.1:${SERVICE_PORT}/load-test" "Medium Load Test"

# Scenario 3: Heavy load
run_load_test "90s" "100" "20" "http://127.0.0.1:${SERVICE_PORT}/load-test" "Heavy Load Test"

# Final status
echo -e "${YELLOW}📊 Final Status Check:${NC}"
echo -e "${BLUE}📋 HPA Status:${NC}"
kubectl get hpa fastapi-hpa

echo -e "${BLUE}📋 Pod Status:${NC}"
kubectl get pods -l app=fastapi-hpa

echo -e "${BLUE}📊 Resource Usage:${NC}"
kubectl top pods -l app=fastapi-hpa 2>/dev/null || echo "Metrics server not available"

echo ""
echo -e "${GREEN}🎉 Visual Load Testing Complete!${NC}"
echo ""
echo -e "${BLUE}📚 What you can do now:${NC}"
echo "1. Open Prometheus: http://127.0.0.1:30090"
echo "   - Go to Graph tab"
echo "   - Query: http_requests_total"
echo "   - Query: http_request_duration_seconds"
echo ""
echo "2. Open Grafana: http://127.0.0.1:30300"
echo "   - Login: admin/admin123"
echo "   - Add Prometheus data source: http://prometheus-service:9090"
echo "   - Create dashboards for:"
echo "     * Request rate"
echo "     * Response time"
echo "     * Error rate"
echo "     * Pod scaling"
echo ""
echo "3. Monitor HPA scaling:"
echo "   kubectl get hpa -w"
echo "   kubectl top pods -l app=fastapi-hpa"
echo ""
echo -e "${YELLOW}🚀 Next: Create custom Grafana dashboards!${NC}" 