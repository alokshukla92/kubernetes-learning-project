#!/bin/bash

# CI/CD Deployment Script for FastAPI Kubernetes Application
# This script can be run locally or in GitHub Actions

set -e  # Exit on any error

echo "🚀 Starting Kubernetes Deployment"
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        echo -e "${RED}❌ kubectl not found. Please install kubectl first.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ kubectl is available${NC}"
}

# Function to check cluster connectivity
check_cluster() {
    echo -e "${BLUE}🔍 Checking cluster connectivity...${NC}"
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✅ Connected to Kubernetes cluster${NC}"
        kubectl cluster-info | head -1
    else
        echo -e "${RED}❌ Cannot connect to Kubernetes cluster${NC}"
        exit 1
    fi
}

# Function to deploy monitoring stack
deploy_monitoring() {
    echo -e "${BLUE}📦 Deploying monitoring stack...${NC}"
    kubectl apply -f k8s/monitoring-setup.yaml
    
    echo -e "${YELLOW}⏳ Waiting for monitoring to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=prometheus --timeout=120s
    kubectl wait --for=condition=ready pod -l app=grafana --timeout=120s
    echo -e "${GREEN}✅ Monitoring stack ready${NC}"
}

# Function to deploy FastAPI application
deploy_fastapi() {
    echo -e "${BLUE}🚀 Deploying FastAPI application...${NC}"
    kubectl apply -f k8s/hpa-fastapi-deployment.yaml
    kubectl apply -f k8s/hpa.yaml
    
    echo -e "${YELLOW}⏳ Waiting for FastAPI to be ready...${NC}"
    kubectl wait --for=condition=ready pod -l app=fastapi-hpa --timeout=300s
    echo -e "${GREEN}✅ FastAPI application ready${NC}"
}

# Function to run health checks
run_health_checks() {
    echo -e "${BLUE}🏥 Running health checks...${NC}"
    
    # Get service port
    SERVICE_PORT=$(kubectl get svc fastapi-hpa-service -o jsonpath='{.spec.ports[0].port}' 2>/dev/null || echo "8000")
    
    # Start port forwarding
    echo -e "${YELLOW}📡 Starting port forward...${NC}"
    kubectl port-forward svc/fastapi-hpa-service 8000:${SERVICE_PORT} &
    PF_PID=$!
    
    # Wait for port forward to be ready
    sleep 5
    
    # Run health checks
    echo -e "${BLUE}🔍 Testing endpoints...${NC}"
    
    # Health endpoint
    if curl -s http://localhost:8000/health | grep -q "healthy"; then
        echo -e "${GREEN}✅ Health endpoint working${NC}"
    else
        echo -e "${RED}❌ Health endpoint failed${NC}"
    fi
    
    # Ready endpoint
    if curl -s http://localhost:8000/ready | grep -q "ready"; then
        echo -e "${GREEN}✅ Ready endpoint working${NC}"
    else
        echo -e "${RED}❌ Ready endpoint failed${NC}"
    fi
    
    # Metrics endpoint
    if curl -s http://localhost:8000/metrics | grep -q "http_requests_total"; then
        echo -e "${GREEN}✅ Metrics endpoint working${NC}"
    else
        echo -e "${RED}❌ Metrics endpoint failed${NC}"
    fi
    
    # Stop port forwarding
    kill $PF_PID 2>/dev/null || true
}

# Function to show deployment status
show_status() {
    echo -e "${BLUE}📊 Deployment Status:${NC}"
    echo ""
    
    echo -e "${YELLOW}Pods:${NC}"
    kubectl get pods -l app=fastapi-hpa
    
    echo ""
    echo -e "${YELLOW}Services:${NC}"
    kubectl get svc -l app=fastapi-hpa
    
    echo ""
    echo -e "${YELLOW}HPA:${NC}"
    kubectl get hpa fastapi-hpa
    
    echo ""
    echo -e "${YELLOW}Monitoring:${NC}"
    kubectl get pods -l app=prometheus
    kubectl get pods -l app=grafana
}

# Function to show access information
show_access_info() {
    echo ""
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}📋 Access Information:${NC}"
    echo "FastAPI Application:"
    echo "  kubectl port-forward svc/fastapi-hpa-service 8000:8000"
    echo "  http://localhost:8000"
    echo ""
    echo "Prometheus:"
    echo "  kubectl port-forward svc/prometheus-service 30090:9090"
    echo "  http://localhost:30090"
    echo ""
    echo "Grafana:"
    echo "  kubectl port-forward svc/grafana-service 30300:3000"
    echo "  http://localhost:30300 (admin/admin123)"
    echo ""
    echo -e "${YELLOW}📈 Load Testing:${NC}"
    echo "  ./scripts/visual-load-test.sh"
    echo ""
}

# Main execution
main() {
    echo -e "${BLUE}🔧 CI/CD Deployment Script${NC}"
    echo "================================"
    
    check_kubectl
    check_cluster
    
    deploy_monitoring
    deploy_fastapi
    run_health_checks
    show_status
    show_access_info
    
    echo -e "${GREEN}✅ Deployment completed!${NC}"
}

# Run main function
main "$@" 