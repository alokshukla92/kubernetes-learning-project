# 🚀 Kubernetes Learning Project

A comprehensive hands-on learning project for mastering Kubernetes concepts through practical implementation. This project demonstrates various Kubernetes features and best practices through a FastAPI + MongoDB application.

## 📚 Learning Phases

### Phase 1: Basic Deployment ✅
- Basic Kubernetes deployments
- Services and networking
- Pod lifecycle management

### Phase 2: Configuration & Secrets ✅
- **ConfigMaps** for non-sensitive configuration
- **Secrets** for sensitive data (base64 encoded)
- Environment variable injection
- MongoDB authentication setup

### Phase 3: Persistent Volumes & StatefulSets ✅
- **Persistent Volume Claims (PVC)** for storage requests
- **Storage Classes** for storage provisioning
- **StatefulSets** for stateful applications
- **Data persistence** across pod restarts
- **volumeClaimTemplates** for automatic PVC creation

### Phase 4: Ingress Controllers & Advanced Networking ✅
- **Ingress Controllers** for external access and load balancing
- **Path-based routing** for multiple services
- **Domain name management** and clean URLs
- **SSL/TLS ready** configuration
- **Rate limiting** and advanced annotations

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   FastAPI App   │    │   MongoDB       │    │   Kubernetes    │
│                 │    │   Database      │    │   Resources     │
│ • Web API       │◄──►│ • Document DB   │    │ • ConfigMaps    │
│ • CRUD ops      │    │ • Authentication│    │ • Secrets       │
│ • Health checks │    │ • Data Storage  │    │ • Deployments   │
└─────────────────┘    └─────────────────┘    │ • Services      │
                                              └─────────────────┘
```

## 🛠️ Technology Stack

- **Backend**: FastAPI (Python)
- **Database**: MongoDB
- **Containerization**: Docker
- **Orchestration**: Kubernetes (Minikube)
- **Configuration**: ConfigMaps & Secrets

## 📁 Project Structure

```
LearnKubernetes/
├── app/
│   ├── main.py              # FastAPI application
│   └── requirements.txt     # Python dependencies
├── k8s/
│   ├── configmap.yaml       # Configuration data
│   ├── mongo-secret.yaml    # Sensitive credentials
│   ├── mongo-deployment.yaml # MongoDB deployment (Phase 2)
│   ├── mongo-statefulset.yaml # MongoDB StatefulSet (Phase 3)
│   ├── storage-class.yaml   # Storage class definition
│   ├── mongo-pvc.yaml       # Persistent Volume Claim
│   ├── ingress.yaml         # Basic Ingress (Phase 4)
│   ├── advanced-ingress.yaml # Advanced Ingress with path routing
│   ├── admin-deployment.yaml # Admin panel service
│   └── fastapi-deployment.yaml # FastAPI deployment
├── scripts/
│   ├── deploy-phase2.sh     # Deployment automation
│   ├── verify-phase2.sh     # Verification script
│   └── test-phase4.sh       # Phase 4 testing script
├── docs/
│   └── PHASE2-README.md     # Phase-specific documentation
├── Dockerfile               # Container definition
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## 🚀 Quick Start

### Prerequisites

- Docker Desktop
- Minikube
- kubectl
- Python 3.9+

### Setup Instructions

1. **Start Minikube**:
   ```bash
   minikube start
   ```

2. **Build Docker Image**:
   ```bash
   docker build -t fastapi-mongo-app:latest .
   ```

3. **Load Image to Minikube**:
   ```bash
   minikube image load fastapi-mongo-app:latest
   ```

4. **Deploy to Kubernetes**:
   ```bash
   ./scripts/deploy-phase2.sh
   ```

5. **Verify Deployment**:
   ```bash
   ./scripts/verify-phase2.sh
   ```

## 🔧 Configuration

### Environment Variables

The application uses the following environment variables (injected via ConfigMaps and Secrets):

**ConfigMap (`fastapi-config`)**:
- `MONGO_HOST`: MongoDB service name
- `MONGO_PORT`: MongoDB port (27017)
- `MONGO_DB`: Database name (testdb)

**Secret (`mongo-secret`)**:
- `MONGO_USER`: MongoDB username (base64 encoded)
- `MONGO_PASS`: MongoDB password (base64 encoded)

### Base64 Encoding

To encode/decode values for secrets:
```bash
# Encode
echo -n "your_password" | base64

# Decode
echo "eW91cl9wYXNzd29yZA==" | base64 -d
```

## 🧪 Testing

### API Endpoints

- `GET /`: Root endpoint with connection status
- `GET /health`: Health check endpoint
- `POST /items/?name=<name>&description=<desc>`: Create new item
- `GET /items/`: Retrieve all items

### Test Commands

```bash
# Test from inside the cluster
kubectl exec <fastapi-pod> -- curl -s http://localhost:8000/

# Test from outside (if NodePort is accessible)
curl http://127.0.0.1:<nodeport>/

# Check MongoDB connection
kubectl exec <mongo-pod> -- mongosh --eval "db.runCommand('ping')"
```

## 📊 Current Status

### ✅ Phase 2 Complete
- ConfigMaps and Secrets properly configured
- FastAPI application connecting to MongoDB
- Environment variables injected correctly
- Database operations working (CRUD)
- Authentication temporarily disabled for learning

### ✅ Phase 3 Complete
- Persistent Volumes and StatefulSets implemented
- MongoDB data persistence across pod restarts
- Storage Classes and PVCs configured
- volumeClaimTemplates for automatic storage management
- StatefulSet provides stable network identities

### ✅ Phase 4 Complete
- Ingress Controllers for external access and load balancing
- Path-based routing for multiple services (FastAPI + Admin Panel)
- Domain name management with clean URLs
- SSL/TLS ready configuration with annotations
- Rate limiting and advanced Ingress features

### 🔄 Next Steps
- **Phase 5**: Advanced Networking & Service Mesh concepts
- Add SSL/TLS certificates for HTTPS
- Implement Horizontal Pod Autoscaling (HPA)
- Add monitoring, logging, and observability

## 🎓 Learning Objectives

### Phase 2 Achievements
- ✅ Understanding ConfigMaps vs Secrets
- ✅ Environment variable injection
- ✅ Base64 encoding for secrets
- ✅ MongoDB deployment and configuration
- ✅ FastAPI deployment with external configuration
- ✅ Troubleshooting Kubernetes deployments
- ✅ Understanding pod lifecycle and restarts

### Phase 3 Achievements
- ✅ Persistent Volume Claims (PVC) and Storage Classes
- ✅ StatefulSets vs Deployments for stateful applications
- ✅ Data persistence across pod restarts
- ✅ volumeClaimTemplates for automatic storage management
- ✅ Understanding PV vs PVC vs StorageClass

### Phase 4 Achievements
- ✅ Ingress Controllers for external access
- ✅ Path-based routing for multiple services
- ✅ Domain name management and clean URLs
- ✅ Load balancing and SSL/TLS configuration
- ✅ Rate limiting and advanced Ingress annotations
- ✅ Multiple services on single domain

## 🔍 Troubleshooting

### Common Issues

1. **MongoDB Connection Issues**:
   ```bash
   kubectl logs <mongo-pod>
   kubectl exec <mongo-pod> -- mongosh --eval "db.runCommand('ping')"
   ```

2. **FastAPI Connection Issues**:
   ```bash
   kubectl logs <fastapi-pod>
   kubectl exec <fastapi-pod> -- env | grep MONGO
   ```

3. **Image Pull Issues**:
   ```bash
   minikube image load fastapi-mongo-app:latest
   kubectl rollout restart deployment/fastapi
   ```

### Useful Commands

```bash
# Check pod status
kubectl get pods

# Check services
kubectl get services

# Check configmaps and secrets
kubectl get configmap
kubectl get secret

# Describe resources
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
```

## 🤝 Contributing

This is a learning project. Feel free to:
- Fork the repository
- Create feature branches
- Submit pull requests
- Report issues
- Suggest improvements

## 📝 License

This project is for educational purposes. Feel free to use and modify as needed.

## 🙏 Acknowledgments

- Kubernetes documentation
- FastAPI framework
- MongoDB documentation
- Minikube project

---

**Happy Learning! 🎉** 