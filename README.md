# terraform-ovh-kubernetes

Module Terraform pour deployer un cluster Kubernetes manage (MKS) sur OVHcloud.

## Features

- Cluster MKS avec choix du plan (`free` / `standard`), version, region et politique de mise a jour
- Support reseau public ou prive (vRack) avec configuration du gateway
- Node pools multiples avec autoscaling, anti-affinite, facturation mensuelle et templates (labels, taints, annotations)
- Customisation de l'API server (admission plugins) et du kube-proxy (iptables / ipvs)
- Authentification OIDC (Dex, Keycloak, Azure AD, Google, etc.)
- Restrictions IP sur l'API server
- Validations integrees sur toutes les variables

## Usage

### Cluster minimal (reseau public)

```hcl
module "kubernetes" {
  source = "git::https://github.com/your-org/terraform-ovh-kubernetes.git?ref=v1.0.0"

  service_name       = "your-ovh-project-id"
  kubernetes_name    = "my-cluster"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"

  kubernetes_nodepools = [
    {
      name        = "default"
      flavor_name = "b3-8"
    },
  ]
}
```

### Cluster complet (vRack + customisations)

```hcl
module "kubernetes" {
  source = "git::https://github.com/your-org/terraform-ovh-kubernetes.git?ref=v1.0.0"

  service_name       = "your-ovh-project-id"
  kubernetes_name    = "my-cluster-prod"
  kubernetes_version = "1.32"
  kubernetes_plan    = "standard"
  kubernetes_region  = "GRA7"

  # Reseau prive (vRack)
  kubernetes_private_network_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  kubernetes_nodes_subnet_id          = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  kubernetes_load_balancers_subnet_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  private_network_configuration = {
    default_vrack_gateway              = "10.0.0.1"
    private_network_routing_as_default = true
  }

  kubernetes_update_policy = "MINIMAL_DOWNTIME"

  kubernetes_customization_apiserver = {
    enabled  = ["NodeRestriction"]
    disabled = ["AlwaysPullImages"]
  }

  # OIDC
  kubernetes_oidc = {
    client_id  = "my-k8s-client"
    issuer_url = "https://auth.example.com/realms/k8s"
    oidc_groups_claim  = ["groups"]
    oidc_groups_prefix = "oidc:"
  }

  kubernetes_ip_restrictions = ["203.0.113.0/24"]

  kubernetes_nodepools = [
    {
      name          = "general"
      flavor_name   = "b3-8"
      desired_nodes = 3
      max_nodes     = 5
      min_nodes     = 1
      autoscale     = true
    },
    {
      name          = "gpu"
      flavor_name   = "t2-45"
      desired_nodes = 1
      max_nodes     = 3
      min_nodes     = 0
      autoscale     = true
      monthly_billed = true

      template = {
        metadata = {
          labels = { "workload" = "gpu" }
        }
        spec = {
          taints = [{
            key    = "nvidia.com/gpu"
            effect = "NoSchedule"
            value  = "true"
          }]
        }
      }
    },
  ]
}
```

Voir aussi [examples/basic](examples/basic/) et [examples/complete](examples/complete/).

## Tests

Les tests utilisent `mock_provider` et ne necessitent pas de credentials OVH :

```bash
terraform init
terraform test
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| ovh | >= 1.0, < 2.0 |

## Providers

| Name | Version |
|------|---------|
| ovh | >= 1.0, < 2.0 |

## Resources

| Name | Type |
|------|------|
| [ovh_cloud_project_kube.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube) | resource |
| [ovh_cloud_project_kube_oidc.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_oidc) | resource |
| [ovh_cloud_project_kube_iprestrictions.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_iprestrictions) | resource |
| [ovh_cloud_project_kube_nodepool.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_nodepool) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| service\_name | OVH Public Cloud project service name (project ID) | `string` | n/a | yes |
| kubernetes\_name | Kubernetes cluster name | `string` | n/a | yes |
| kubernetes\_version | Kubernetes version (e.g. 1.32, 1.33) | `string` | n/a | yes |
| kubernetes\_region | Kubernetes cluster region (e.g. GRA7, SBG5, BHS5) | `string` | n/a | yes |
| kubernetes\_plan | Kubernetes plan: free or standard | `string` | `"free"` | no |
| kubernetes\_proxy\_mode | Kube-proxy mode: iptables or ipvs | `string` | `"iptables"` | no |
| kubernetes\_update\_policy | Cluster update policy: ALWAYS\_UPDATE, MINIMAL\_DOWNTIME, or NEVER\_UPDATE | `string` | `null` | no |
| kubernetes\_private\_network\_id | The ID of the private network to attach to the Kubernetes cluster | `string` | `null` | no |
| kubernetes\_nodes\_subnet\_id | The ID of the subnet for Kubernetes nodes | `string` | `null` | no |
| kubernetes\_load\_balancers\_subnet\_id | The ID of the subnet for Kubernetes load balancers | `string` | `null` | no |
| private\_network\_configuration | Private network configuration (vRack gateway) | `object({...})` | `null` | no |
| kubernetes\_customization\_apiserver | Kubernetes API server admission plugins customization | `object({...})` | `{}` | no |
| kubernetes\_customization\_kube\_proxy | Kubernetes kube-proxy customization (iptables or ipvs settings) | `object({...})` | `{}` | no |
| kubernetes\_oidc | OIDC configuration for the Kubernetes cluster (client\_id, issuer\_url, claims, etc.) | `object({...})` | `null` | no |
| kubernetes\_ip\_restrictions | List of CIDR blocks to restrict Kubernetes API access. Empty list means no restriction. | `list(string)` | `[]` | no |
| kubernetes\_nodepools | List of Kubernetes node pools to create | `list(object({...}))` | `[]` | no |

## Outputs

| Name | Description | Sensitive |
|------|-------------|:---------:|
| kube\_id | Managed Kubernetes Service ID | no |
| kube\_version | Kubernetes version | no |
| kube\_status | Cluster status | no |
| kubeconfig | Full kubeconfig file content | yes |
| kubeconfig\_attributes | Kubeconfig parsed attributes | yes |
| nodepools | Map of node pool name to node pool attributes | no |
<!-- END_TF_DOCS -->

## License

MIT
