#!/bin/bash

# Health Check Script for 3-Tier Application
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo "🔍 Checking 3-Tier Application Health"
echo "====================================="

# Check Kubernetes cluster
print_status "Checking Kubernetes cluster..."
if kubectl cluster-info &> /dev/null; then
    print_success "Kubernetes cluster is accessible"
else
    print_error "Cannot connect to Kubernetes cluster"
    exit 1
fi

echo ""

# Check pods
print_status "Checking pod status..."
kubectl get pods --no-headers | while read pod status rest; do
    if [[ $status == *"Running"* ]]; then
        print_success "Pod $pod is running"
    elif [[ $status == *"Pending"* ]]; then
        print_status "Pod $pod is pending"
    else
        print_error "Pod $pod is in status: $status"
    fi
done

echo ""

# Check services
print_status "Checking services..."
kubectl get services --no-headers | grep -E "(backend|frontend|postgres)" | while read service type cluster_ip external_ip ports rest; do
    print_success "Service $service is available at $cluster_ip:$ports"
done

echo ""

# Check deployments
print_status "Checking deployments..."
kubectl get deployments --no-headers | while read deployment ready uptodate available rest; do
    IFS='/' read -ra READY <<< "$ready"
    if [ "${READY[0]}" -eq "${READY[1]}" ]; then
        print_success "Deployment $deployment is fully ready ($ready)"
    else
        print_error "Deployment $deployment is not ready ($ready)"
    fi
done

echo ""

# Test backend health endpoint
print_status "Testing backend health endpoint..."
if kubectl exec -it $(kubectl get pods -l app=backend -o jsonpath='{.items[0].metadata.name}') -- curl -f http://localhost:5000/health &> /dev/null; then
    print_success "Backend health check passed"
else
    print_error "Backend health check failed"
fi

echo ""

# Test frontend accessibility
print_status "Testing frontend accessibility..."
if kubectl exec -it $(kubectl get pods -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- curl -f http://localhost &> /dev/null; then
    print_success "Frontend is accessible"
else
    print_error "Frontend is not accessible"
fi

echo ""
print_success "Health check completed!"
