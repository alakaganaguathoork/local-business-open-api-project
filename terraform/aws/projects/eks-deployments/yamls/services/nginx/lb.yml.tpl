apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
  namespace: nginx-ns
  labels:
    app: nginx
  annotations:
    # Specify the load balancer scheme as internet-facing to create a public-facing Network Load Balancer (NLB)
    service.beta.kubernetes.io/aws-load-balancer-scheme: internet-facing
    service.beta.kubernetes.io/aws-load-balancer-security-groups: ${sg_ids} 
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
      protocol: TCP
  type: LoadBalancer
  # Specify the new load balancer class for NLB as part of EKS Auto Mode feature
  # For clusters with Auto Mode enabled, this field can be omitted as it's the default
  loadBalancerClass: eks.amazonaws.com/nlb