#!/bin/bash

# Rolling Update Script for Backend Deployment
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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

# Check arguments
if [ $# -eq 0 ]; then
    print_error "Usage: $0 <new-image-tag>"
    print_error "Example: $0 v2.0.0"
    exit 1
fi

NEW_TAG=$1
DEPLOYMENT_NAME="backend"
IMAGE_NAME="your-dockerhub-username/3tier-backend"

print_status "Starting rolling update for $DEPLOYMENT_NAME..."
print_status "New image: $IMAGE_NAME:$NEW_TAG"

# Update the deployment image
kubectl set image deployment/$DEPLOYMENT_NAME backend=$IMAGE_NAME:$NEW_TAG

# Monitor the rollout
print_status "Monitoring rollout progress..."
kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=300s

# Check rollout result
if kubectl rollout status deployment/$DEPLOYMENT_NAME --timeout=30s > /dev/null 2>&1; then
    print_success "Rolling update completed successfully!"
    echo ""
    print_status "Current deployment status:"
    kubectl get pods -l app=$DEPLOYMENT_NAME
    echo ""
    print_status "Deployment details:"
    kubectl describe deployment/$DEPLOYMENT_NAME | grep -A 5 "Containers:"
else
    print_error "Rolling update failed!"
    print_warning "To rollback: kubectl rollout undo deployment/$DEPLOYMENT_NAME"
    exit 1
fi
