1. Notes

* Get Service endpoint:

    ```bash
    SERVICE_IP=$(kubectl get svc -n <namespace> <service-name> -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
    echo $SERVICE_IP
    ```
