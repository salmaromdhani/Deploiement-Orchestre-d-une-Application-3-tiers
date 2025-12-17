# 3-Tier Application: React + Node.js + PostgreSQL

A complete DevOps implementation of a 3-tier web application with full CI/CD pipeline, containerization, and Kubernetes orchestration.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React Frontend│────│ Node.js Backend │────│ PostgreSQL DB   │
│   (Port 80/3000)│    │   (Port 5000)   │    │   (Port 5432)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

- Docker & Docker Compose
- Kubernetes (Minikube for local development)
- kubectl
- Node.js 18+ (for local development)
- GitHub Account (for CI/CD)

## 🚀 Quick Start

### Option 1: Local Development with Docker Compose

```bash
# Clone the repository
git clone <your-repo-url>
cd deploiement-orchestre-d-une-application-3-tiers

# Start all services
docker-compose up --build

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:5000
```

### Option 2: Kubernetes Deployment

```bash
# Start Minikube
minikube start

# Enable ingress
minikube addons enable ingress

# Deploy to Kubernetes
./deploy.sh

# Access the application
# Frontend: http://localhost (via Ingress)
```

## 🐳 Docker Setup

### Build Commands

```bash
# Build backend image
cd backend
docker build -t your-dockerhub-username/3tier-backend:latest .

# Build frontend image
cd frontend
docker build -t your-dockerhub-username/3tier-frontend:latest .

# Build all images
docker-compose build
```

### Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Push images
docker push your-dockerhub-username/3tier-backend:latest
docker push your-dockerhub-username/3tier-frontend:latest
```

## ☸️ Kubernetes Deployment

### Manual Deployment

```bash
# Apply all manifests
kubectl apply -f k8s-manifests/

# Check status
kubectl get pods
kubectl get services
kubectl get deployments
```

### Access Services

```bash
# Port forward for local access
kubectl port-forward svc/backend-service 5000:5000
kubectl port-forward svc/frontend-service 3000:80

# Or use ingress (Minikube)
minikube tunnel
# Access at: http://localhost
```

## ⚙️ Configuration

### Environment Variables

**Backend:**
- `DB_HOST`: PostgreSQL hostname (default: postgres-service)
- `DB_USER`: Database user (default: postgres)
- `DB_PASSWORD`: Database password
- `DB_NAME`: Database name (default: appdb_devops)
- `DB_PORT`: Database port (default: 5432)

**Database Secrets:**
Update `k8s-manifests/db-secret.yaml` with your values:

```yaml
data:
  POSTGRES_USER: <base64-encoded-username>
  POSTGRES_PASSWORD: <base64-encoded-password>
  POSTGRES_DB: <base64-encoded-database-name>
```

## 🔄 CI/CD Pipeline

### GitHub Actions Setup

1. **Create Secrets:**
   - Go to your GitHub repo → Settings → Secrets and variables → Actions
   - Add: `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN`

2. **Update Image Names:**
   - Replace `your-dockerhub-username` in Kubernetes manifests with your actual Docker Hub username

3. **Push to Main Branch:**
   - The pipeline automatically runs on push to main/master branch
   - Builds, tests, pushes images, and deploys to Kubernetes

### Pipeline Stages

1. **Test:** Run unit tests for frontend and backend
2. **Build:** Create Docker images with git SHA tags
3. **Push:** Upload images to Docker Hub
4. **Deploy:** Apply Kubernetes manifests and verify rollout

## 📊 Monitoring & Scaling

### Check Application Health

```bash
# Get all pods
kubectl get pods

# Check pod logs
kubectl logs -l app=backend
kubectl logs -l app=frontend

# Check services
kubectl get services

# Check ingress
kubectl get ingress
```

### Scaling Operations

```bash
# Scale backend to 3 replicas
kubectl scale deployment backend --replicas=3

# Or use the provided script
./scripts/scale-backend.sh 3

# Check scaling status
kubectl get pods -l app=backend
```

### Rolling Updates

```bash
# Update backend image
kubectl set image deployment/backend backend=your-dockerhub-username/3tier-backend:v2.0.0

# Monitor rollout
kubectl rollout status deployment/backend

# Rollback if needed
kubectl rollout undo deployment/backend
```

## 🔧 Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

**Database connection issues:**
```bash
# Check database pod
kubectl logs -l app=postgres

# Test database connectivity
kubectl exec -it <postgres-pod> -- psql -U postgres -d appdb_devops
```

**Image pull errors:**
```bash
# Check if images exist on Docker Hub
docker pull your-dockerhub-username/3tier-backend:latest

# Update image pull policy
kubectl patch deployment backend -p '{"spec":{"template":{"spec":{"containers":[{"name":"backend","imagePullPolicy":"Always"}]}}}}'
```

### Database Schema

The application expects a `users` table:

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    email VARCHAR(255)
);
```

## 🧪 Testing

### Local Testing

```bash
# Backend tests
cd backend && npm test

# Frontend tests
cd frontend && npm test
```

### API Endpoints

- `GET /health` - Health check
- `GET /api/users` - Get all users
- `POST /api/users` - Create user (body: {name, email})

## 📁 Project Structure

```
.
├── backend/                 # Node.js API server
│   ├── Dockerfile
│   ├── package.json
│   └── server.js
├── frontend/                # React application
│   ├── Dockerfile
│   ├── package.json
│   ├── public/
│   └── src/
├── k8s-manifests/          # Kubernetes manifests
│   ├── backend-deployment.yaml
│   ├── backend-service.yaml
│   ├── frontend-deployment.yaml
│   ├── frontend-service.yaml
│   ├── postgres-deployment.yaml
│   ├── postgres-service.yaml
│   ├── db-secret.yaml
│   └── ingress.yaml
├── scripts/                 # Utility scripts
│   └── scale-backend.sh
├── .github/workflows/       # CI/CD pipeline
│   └── ci-cd.yml
├── docker-compose.yml       # Local development
├── deploy.sh               # Deployment script
└── README.md
```

## 🚀 Production Considerations

- **Security:** Use Kubernetes secrets for all sensitive data
- **Monitoring:** Implement proper logging and monitoring
- **Backup:** Set up PostgreSQL backups
- **Scaling:** Configure horizontal pod autoscaling
- **Networking:** Use proper ingress controllers and TLS certificates

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests locally
5. Push to your branch
6. Create a Pull Request

---

**Happy Deploying! 🎉**
