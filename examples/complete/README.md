# Complete example

Creates the cluster `my-cluster-prod` on plan `standard`, in an existing
private network (vRack), with an update policy, API server admission plugins,
OIDC, IP restrictions, and two autoscaled node pools, one of them tainted for
GPU workloads.

```bash
export OVH_ENDPOINT=ovh-eu OVH_CLIENT_ID=... OVH_CLIENT_SECRET=...
terraform init
terraform apply \
  -var service_name=<Public Cloud project ID> \
  -var private_network_id=<private network ID> \
  -var nodes_subnet_id=<subnet ID> \
  -var load_balancers_subnet_id=<subnet ID>
```

The private network and its subnets must exist in `GRA7`, with
`10.0.0.1` as the vRack gateway.
