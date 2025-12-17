#!/bin/bash

# Script to scale the backend deployment
set -e

REPLICAS=${1:-3}

echo "🔄 Scaling backend deployment to $REPLICAS replicas..."

kubectl scale deployment backend --replicas=$REPLICAS

echo "⏳ Waiting for rollout to complete..."
kubectl rollout status deployment/backend --timeout=300s

echo "✅ Backend scaled successfully!"
kubectl get pods -l app=backend
