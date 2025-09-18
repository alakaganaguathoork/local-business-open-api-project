# EKS Notes

## EKS Auto Mode

igw -->
vpc -->
public subnet in az -->
private subnet in az -->
cluster IAM role (AmazonEKSComputePolicy, AmazonEKSBlockStoragePolicy, AmazonEKSLoadBalancingPolicy, AmazonEKSNetworkingPolicy, AmazonEKSClusterPolicy) -->
Node IAM role (AmazonEKSWorkerNodeMinimalPolicy, AmazonEC2ContainerRegistryPullOnly) -->
Access policy (AmazonEKSViewPolicy??? - to operate kubectl locally)

### Notes

1. Update config context:

    ```bash
    aws eks update-kubeconfig --name "terraform-test"
    ```

2. Check access:

   ```bash
    kubectl get nodegroups
   ```

3. (!) Provisioned node groups won't delete if `aws_eks_node_group.scaling_config.min_size` > 0.

## EKS standard (manual configuration)

igw -->
vpc -->
public subnet -->
private subnet/s -->
cluster -->
namespace -->
node groups -->
auto-scaling