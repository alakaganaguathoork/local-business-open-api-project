# Notes

* Get Service endpoint:

    ```bash
    SERVICE_IP=$(kubectl get svc -n <namespace> <service-name> -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo $SERVICE_IP
    ```

* Get ArgoCD admin password:

    ```bash
    ARGOCD_ADMIN_PASSWORD=$(kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
    echo $ARGOCD_ADMIN_PASSWORD
    ```

* Port forward ArgoCD server:

    ```bash
    kubectl port-forward svc/argocd-server -n default 8080:443
    ```

terraform output -raw eks_sg_ids | tr -d '[]" ' | tr ',' '\n' > .sg-ids.output
