#!/bin/bash

echo "================================================"
echo "ECR Secret Refresh - Kubernetes Deployment"
echo "================================================"
echo ""

# Read namespace from kustomization.yaml or use default
NAMESPACE=${NAMESPACE:-$(grep "^namespace:" kustomization.yaml 2>/dev/null | awk '{print $2}')}
NAMESPACE=${NAMESPACE:-"tenant-red-identity"}

echo "Target namespace: ${NAMESPACE}"
echo ""

# Check if namespace exists
echo "Checking if namespace ${NAMESPACE} exists..."
if kubectl get namespace ${NAMESPACE} 2>/dev/null; then
    echo "✓ Namespace ${NAMESPACE} exists"
else
    echo "Creating namespace ${NAMESPACE}..."
    kubectl create namespace ${NAMESPACE}
    echo "✓ Namespace created"
fi
echo ""

# Apply with Kustomize
echo "Applying manifests with Kustomize..."
kubectl apply -k .
if [ $? -eq 0 ]; then
    echo "✓ All resources applied successfully"
else
    echo "✗ Failed to apply resources"
    exit 1
fi
echo ""

echo "================================================"
echo "Deployment completed successfully!"
echo "================================================"
echo ""
echo "Namespace: ${NAMESPACE}"
echo ""
echo "To verify the deployment:"
echo "  kubectl get cronjob -n ${NAMESPACE}"
echo ""
echo "To manually trigger the job (for testing):"
echo "  kubectl create job --from=cronjob/ecr-secret-refresh ecr-secret-refresh-manual -n ${NAMESPACE}"
echo ""
echo "To view job logs:"
echo "  kubectl get jobs -n ${NAMESPACE}"
echo "  kubectl logs job/ecr-secret-refresh-manual -n ${NAMESPACE}"
echo ""
echo "To check the secret:"
echo "  kubectl get secret eudistack-stg-ecr-secret -n ${NAMESPACE}"
echo ""
echo "To change namespace, edit kustomization.yaml and run this script again"
echo ""
