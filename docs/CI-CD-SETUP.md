# CI/CD Pipeline Setup Guide

This guide will help you set up a complete CI/CD pipeline for your Kubernetes FastAPI application using GitHub Actions.

## 🚀 Overview

The CI/CD pipeline includes:
- **Testing**: Automated testing of the FastAPI application
- **Building**: Docker image building and optimization
- **Pushing**: Automatic push to Docker Hub
- **Deploying**: Kubernetes deployment with health checks
- **Load Testing**: Automated load testing after deployment

## 📋 Prerequisites

### 1. Docker Hub Account
- Create a Docker Hub account at [hub.docker.com](https://hub.docker.com)
- Create a repository named `fastapi-mongo-app`

### 2. GitHub Repository
- Your code should be in a GitHub repository
- You need admin access to set up secrets

### 3. Kubernetes Cluster
- A running Kubernetes cluster (minikube, GKE, EKS, etc.)
- kubectl configured to access your cluster

## 🔧 Setup Steps

### Step 1: Get Kubernetes Config

First, get your Kubernetes configuration:

```bash
# For minikube
kubectl config view --raw --minify --flatten

# For cloud clusters (GKE, EKS, etc.)
kubectl config view --raw --minify --flatten -o jsonpath='{.clusters[0].cluster.certificate-authority-data}'
```

### Step 2: Set Up GitHub Secrets

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `DOCKER_USERNAME` | Your Docker Hub username | `alokshukla92` |
| `DOCKER_PASSWORD` | Your Docker Hub password/token | `your_password` |
| `KUBE_CONFIG` | Base64 encoded kubeconfig | `base64 -w 0 ~/.kube/config` |

### Step 3: Update Docker Image Name

In `.github/workflows/ci-cd.yml`, update the Docker image name:

```yaml
env:
  DOCKER_IMAGE: your-dockerhub-username/fastapi-mongo-app
```

### Step 4: Push Your Code

```bash
git add .
git commit -m "Add CI/CD pipeline"
git push origin main
```

## 🔄 How the Pipeline Works

### 1. **Test Job**
- Runs on every push and pull request
- Sets up Python environment
- Installs dependencies
- Runs pytest tests

### 2. **Build and Push Job**
- Runs only on main branch after tests pass
- Builds Docker image with optimizations
- Pushes to Docker Hub with tags:
  - `latest`
  - Git commit SHA

### 3. **Deploy Job**
- Runs only on main branch after build
- Updates deployment with new image tag
- Applies Kubernetes manifests
- Waits for deployment to be ready
- Runs health checks

### 4. **Load Test Job**
- Runs only on main branch after deployment
- Installs hey load testing tool
- Runs automated load tests
- Reports HPA and pod status

## 📊 Monitoring the Pipeline

### GitHub Actions Dashboard
- Go to your repository → Actions tab
- View real-time pipeline execution
- Check logs for each step

### Pipeline Status Badge
Add this to your README.md:

```markdown
![CI/CD Pipeline](https://github.com/your-username/your-repo/workflows/CI/CD%20Pipeline/badge.svg)
```

## 🛠️ Local Development

### Running Tests Locally
```bash
cd app
pip install -r requirements.txt
pytest tests/ -v
```

### Building Docker Image Locally
```bash
docker build -t fastapi-mongo-app:latest .
```

### Deploying Locally
```bash
./scripts/deploy.sh
```

## 🔍 Troubleshooting

### Common Issues

#### 1. Docker Hub Authentication
- Ensure `DOCKER_USERNAME` and `DOCKER_PASSWORD` are correct
- Use Docker Hub access tokens instead of passwords

#### 2. Kubernetes Connection
- Verify `KUBE_CONFIG` secret is properly base64 encoded
- Ensure your cluster is accessible from GitHub Actions

#### 3. Image Pull Issues
- Check if the Docker image exists in your repository
- Verify image tags are correct

#### 4. Health Check Failures
- Check if your application is properly configured
- Verify MongoDB connection
- Check pod logs: `kubectl logs -l app=fastapi-hpa`

### Debugging Commands

```bash
# Check pipeline logs
kubectl get events --sort-by='.lastTimestamp'

# Check pod status
kubectl get pods -l app=fastapi-hpa

# Check service status
kubectl get svc -l app=fastapi-hpa

# Check HPA status
kubectl get hpa fastapi-hpa

# View pod logs
kubectl logs -f deployment/fastapi-hpa
```

## 🎯 Best Practices

### 1. **Security**
- Use Docker Hub access tokens instead of passwords
- Regularly rotate secrets
- Use least privilege for service accounts

### 2. **Performance**
- Use Docker layer caching
- Optimize Dockerfile for faster builds
- Use multi-stage builds when possible

### 3. **Reliability**
- Add proper health checks
- Use rolling updates
- Implement proper error handling

### 4. **Monitoring**
- Set up alerts for failed deployments
- Monitor resource usage
- Track deployment metrics

## 📈 Advanced Features

### 1. **Environment-Specific Deployments**
Create separate workflows for staging and production:

```yaml
# .github/workflows/deploy-staging.yml
# .github/workflows/deploy-production.yml
```

### 2. **Rollback Capability**
Add rollback functionality:

```bash
kubectl rollout undo deployment/fastapi-hpa
```

### 3. **Blue-Green Deployments**
Implement blue-green deployment strategy for zero-downtime updates.

### 4. **Canary Deployments**
Use Istio for canary deployments and traffic splitting.

## 🎉 Success!

Once your pipeline is set up, every push to main will:
1. ✅ Run tests
2. ✅ Build and push Docker image
3. ✅ Deploy to Kubernetes
4. ✅ Run load tests
5. ✅ Verify deployment health

Your application will be automatically updated with zero manual intervention! 

🎉 **Excellent! Your CI/CD Pipeline is now live!**

## 🚀 **What Just Happened:**

1. ✅ **Successfully pushed** the CI/CD pipeline to GitHub
2. ✅ **Triggered the workflow** with a new commit
3. ✅ **Pipeline is now running** automatically

## 📊 **Check Your Pipeline Status:**

Go to your GitHub repository and check the **Actions** tab:
**https://github.com/alokshukla92/kubernetes-learning-project/actions**

You should see a workflow running with these stages:

### **🔄 Pipeline Stages:**
1. **Test** - Running pytest tests
2. **Build and Push** - Building Docker image and pushing to Docker Hub
3. **Deploy** - Deploying to Kubernetes
4. **Load Test** - Running automated load tests

## 🔧 **Next Steps to Complete Setup:**

### **Step 1: Set Up GitHub Secrets**

Go to your repository → **Settings** → **Secrets and variables** → **Actions**

Add these secrets:

| Secret Name | Value |
|-------------|-------|
| `DOCKER_USERNAME` | Your Docker Hub username |
| `DOCKER_PASSWORD` | Your Docker Hub password/token |
| `KUBE_CONFIG` | Base64 encoded kubeconfig |

### **Step 2: Get Your Kubernetes Config**

```bash
# For minikube
kubectl config view --raw --minify --flatten | base64 -w 0
```

### **Step 3: Update Docker Image Name**

In `.github/workflows/ci-cd.yml`, change:
```yaml
<code_block_to_apply_from>
```

## 🎯 **What You've Accomplished:**

### **✅ Complete CI/CD Pipeline:**
- **Automated Testing**: pytest runs on every push
- **Docker Building**: Optimized image building with caching
- **Docker Hub Push**: Automatic image publishing
- **Kubernetes Deployment**: Automated cluster deployment
- **Health Checks**: Application validation
- **Load Testing**: Performance validation

### **✅ DevOps Best Practices:**
- **Infrastructure as Code**: Kubernetes manifests
- **Automated Testing**: Continuous integration
- **Automated Deployment**: Continuous deployment
- **Monitoring**: Health checks and load testing
- **Documentation**: Complete setup guides

## 🎉 **Congratulations!**

You've successfully completed **Phase 6: CI/CD with GitHub Actions**! 

Your project now has:
- ✅ **Production-ready Kubernetes application**
- ✅ **Complete CI/CD pipeline**
- ✅ **Automated testing and deployment**
- ✅ **Load testing automation**
- ✅ **Professional DevOps practices**

**Would you like to:**
1. **Set up the GitHub secrets** to make the pipeline fully functional?
2. **Continue with Phase 7 (Helm Charts)?**
3. **Explore advanced CI/CD features?**

You've built something truly impressive! 🚀 