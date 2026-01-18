#!/bin/bash

# Notes App Kubernetes Deployment Script
set -e

echo "🚀 Deploying Notes App to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster."
    echo "Make sure your cluster is running and kubectl is configured."
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Apply manifests in order
echo "📦 Creating namespace..."
kubectl apply -f namespace.yaml

echo "🔧 Creating ConfigMap..."
kubectl apply -f configmap.yaml

echo "💾 Creating PersistentVolume..."
kubectl apply -f persistent-volume.yaml

echo "🚀 Creating Deployment..."
kubectl apply -f deployment.yaml

echo "🌐 Creating Service..."
kubectl apply -f service.yaml

echo "📈 Creating HPA..."
kubectl apply -f hpa.yaml

echo "🔗 Creating Ingress..."
kubectl apply -f ingress.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/notes-app-deployment -n notes-app

# Get deployment status
echo ""
echo "📊 Deployment Status:"
kubectl get pods -n notes-app
kubectl get services -n notes-app
kubectl get ingress -n notes-app

# Get access URLs
echo ""
echo "🌍 Access URLs:"
echo "NodePort: http://localhost:30000"
echo "Ingress: http://notes-app.local"

# Show logs
echo ""
echo "📝 Recent logs:"
kubectl logs -l app=notes-app -n notes-app --tail=10

echo ""
echo "✅ Notes App deployed successfully!"
echo "🔍 Monitor with: kubectl get pods -n notes-app -w"