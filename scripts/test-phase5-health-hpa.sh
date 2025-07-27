#!/bin/bash

echo "🚀 Phase 5: Health Checks + Autoscaling - Concept Demonstration"
echo "==============================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📚 Phase 5 Learning Objectives:${NC}"
echo "1. Health Checks (Liveness + Readiness probes)"
echo "2. Horizontal Pod Autoscaler (HPA)"
echo "3. Load Testing with hey/wrk"
echo "4. Resource monitoring and scaling"
echo ""

echo -e "${BLUE}🔍 Current Kubernetes Resources:${NC}"
echo -e "${YELLOW}📋 Deployments:${NC}"
kubectl get deployments | grep fastapi
echo ""

echo -e "${YELLOW}📋 HPA Status:${NC}"
kubectl get hpa
echo ""

echo -e "${YELLOW}📋 Services:${NC}"
kubectl get services | grep fastapi
echo ""

echo -e "${BLUE}📖 Health Check Concepts:${NC}"
echo ""
echo -e "${GREEN}✅ Readiness Probe (/ready):${NC}"
echo "   - Checks if pod is ready to serve traffic"
echo "   - Tests MongoDB connection"
echo "   - Returns 200 if ready, 503 if not ready"
echo "   - Kubernetes won't send traffic until ready"
echo ""

echo -e "${GREEN}✅ Liveness Probe (/live):${NC}"
echo "   - Checks if pod is alive and responsive"
echo "   - Basic application health check"
echo "   - Returns 200 if alive, 500 if dead"
echo "   - Kubernetes restarts pod if fails"
echo ""

echo -e "${GREEN}✅ Startup Probe (/health):${NC}"
echo "   - Gives app time to start properly"
echo "   - Prevents premature liveness probe failures"
echo "   - Useful for slow-starting applications"
echo ""

echo -e "${BLUE}⚡ HPA Configuration:${NC}"
echo ""
echo -e "${YELLOW}📊 Resource Limits:${NC}"
echo "   - CPU Request: 100m (0.1 core)"
echo "   - CPU Limit: 500m (0.5 core)"
echo "   - Memory Request: 128Mi"
echo "   - Memory Limit: 256Mi"
echo ""

echo -e "${YELLOW}📈 Scaling Rules:${NC}"
echo "   - CPU Threshold: 70% utilization"
echo "   - Memory Threshold: 80% utilization"
echo "   - Min Replicas: 2"
echo "   - Max Replicas: 10"
echo ""

echo -e "${YELLOW}🔄 Scaling Behavior:${NC}"
echo "   - Scale Up: 100% increase every 15s"
echo "   - Scale Down: 10% decrease every 60s"
echo "   - Stabilization Window: 60s up, 300s down"
echo ""

echo -e "${BLUE}🧪 Load Testing Scenarios:${NC}"
echo ""
echo -e "${GREEN}📈 Light Load:${NC}"
echo "   - 10 requests/sec for 30 seconds"
echo "   - Expected: No scaling needed"
echo ""

echo -e "${GREEN}📈 Medium Load:${NC}"
echo "   - 50 requests/sec for 60 seconds"
echo "   - Expected: Possible scaling to 3-4 replicas"
echo ""

echo -e "${GREEN}📈 Heavy Load:${NC}"
echo "   - 100 requests/sec for 90 seconds"
echo "   - Expected: Scaling to 6-8 replicas"
echo ""

echo -e "${BLUE}📋 FastAPI Health Endpoints:${NC}"
echo ""
echo -e "${YELLOW}GET /health${NC}"
echo "   - Basic health check"
echo "   - Returns: {\"status\": \"healthy\", \"mongo_connected\": true}"
echo ""

echo -e "${YELLOW}GET /ready${NC}"
echo "   - Readiness check"
echo "   - Tests MongoDB connection"
echo "   - Returns: {\"status\": \"ready\", \"mongo_connected\": true}"
echo ""

echo -e "${YELLOW}GET /live${NC}"
echo "   - Liveness check"
echo "   - Basic app responsiveness"
echo "   - Returns: {\"status\": \"alive\", \"uptime_seconds\": 123}"
echo ""

echo -e "${YELLOW}GET /metrics${NC}"
echo "   - Basic metrics endpoint"
echo "   - Returns: uptime, connection status, etc."
echo ""

echo -e "${BLUE}🔧 Kubernetes Commands:${NC}"
echo ""
echo -e "${YELLOW}Check HPA Status:${NC}"
echo "   kubectl get hpa"
echo ""

echo -e "${YELLOW}Check Pod Resources:${NC}"
echo "   kubectl top pods -l app=fastapi-hpa"
echo ""

echo -e "${YELLOW}Describe HPA:${NC}"
echo "   kubectl describe hpa fastapi-hpa"
echo ""

echo -e "${YELLOW}Check Pod Logs:${NC}"
echo "   kubectl logs -l app=fastapi-hpa"
echo ""

echo -e "${YELLOW}Port Forward for Testing:${NC}"
echo "   kubectl port-forward svc/fastapi-hpa-service 8080:8000"
echo ""

echo -e "${GREEN}🎉 Phase 5 Concepts Demonstrated!${NC}"
echo ""
echo -e "${BLUE}📚 Key Learnings:${NC}"
echo "✅ Health checks ensure application reliability"
echo "✅ HPA provides automatic scaling based on demand"
echo "✅ Resource limits prevent resource exhaustion"
echo "✅ Load testing validates scaling behavior"
echo "✅ Monitoring helps track performance"
echo ""
echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "1. Fix image issues and deploy working pods"
echo "2. Run load testing with hey tool"
echo "3. Monitor HPA scaling behavior"
echo "4. Add advanced monitoring (Prometheus/Grafana)" 