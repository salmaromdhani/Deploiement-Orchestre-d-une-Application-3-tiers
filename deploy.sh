#!/bin/bash

# 3-Tier Application Deployment Script
set -e

echo "🚀 Starting 3-Tier Application Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install it first."
    exit 1
fi

# Check if we're connected to a cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Not connected to a Kubernetes cluster. Please configure kubectl."
    exit 1
fi

# Apply Kubernetes manifests
print_status "Applying Kubernetes manifests..."

kubectl apply -f k8s-manifests/db-secret.yaml
kubectl apply -f k8s-manifests/postgres-deployment.yaml
kubectl apply -f k8s-manifests/postgres-service.yaml
kubectl apply -f k8s-manifests/backend-deployment.yaml
kubectl apply -f k8s-manifests/backend-service.yaml
kubectl apply -f k8s-manifests/frontend-deployment.yaml
kubectl apply -f k8s-manifests/frontend-service.yaml
kubectl apply -f k8s-manifests/ingress.yaml

# Wait for deployments to be ready
print_status "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/postgres

print_status "Waiting for backend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/backend

print_status "Waiting for frontend to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/frontend

# Get service information
print_success "Deployment completed successfully!"
echo ""
print_status "Service Information:"
echo "=========================="
kubectl get services
echo ""
print_status "Pod Status:"
echo "================"
kubectl get pods
echo ""
print_status "To access the application:"
echo "Frontend: http://localhost (via Ingress)"
echo "Backend API: kubectl port-forward svc/backend-service 5000:5000"
echo "PostgreSQL: kubectl port-forward svc/postgres-service 5432:5432"
echo ""
print_warning "Don't forget to update image names in k8s-manifests/ to point to your Docker Hub repository!"
