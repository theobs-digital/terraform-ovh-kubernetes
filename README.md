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
  source = "git::https://github.com/theobs-digital/terraform-ovh-kubernetes.git?ref=v2.0.0"

  service_name       = "your-ovh-project-id"
  name               = "my-cluster"
  kubernetes_version = "1.32"
  region             = "GRA7"

  nodepools = {
    default = {
      flavor_name = "b3-8"
    }
  }
}
```

### Cluster complet (vRack + customisations)

```hcl
module "kubernetes" {
  source = "git::https://github.com/theobs-digital/terraform-ovh-kubernetes.git?ref=v2.0.0"

  service_name       = "your-ovh-project-id"
  name               = "my-cluster-prod"
  kubernetes_version = "1.32"
  plan               = "standard"
  region             = "GRA7"

  # Reseau prive (vRack)
  private_network_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  nodes_subnet_id          = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  load_balancers_subnet_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  private_network_configuration = {
    default_vrack_gateway              = "10.0.0.1"
    private_network_routing_as_default = true
  }

  update_policy = "MINIMAL_DOWNTIME"

  customization_apiserver = {
    admissionplugins = {
      enabled  = ["NodeRestriction"]
      disabled = ["AlwaysPullImages"]
    }
  }

  # OIDC
  oidc = {
    client_id  = "my-k8s-client"
    issuer_url = "https://auth.example.com/realms/k8s"
    oidc_groups_claim  = ["groups"]
    oidc_groups_prefix = "oidc:"
  }

  ips = ["203.0.113.0/24"]

  nodepools = {
    general = {
      flavor_name   = "b3-8"
      desired_nodes = 3
      max_nodes     = 5
      min_nodes     = 1
      autoscale     = true
    }
    gpu = {
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
    }
  }
}
```

Voir aussi [examples/basic](examples/basic/) et [examples/complete](examples/complete/).

## Tests

Les tests utilisent `mock_provider` et ne necessitent pas de credentials OVH :

```bash
terraform init
terraform test
```

## Requirements

| | Version | Checked with |
|---|---|---|
| Terraform | `>= 1.5` | 1.5.7 and 1.16.5 |
| Provider [`ovh/ovh`](https://registry.terraform.io/providers/ovh/ovh/latest) | `~> 2.7` | 2.7.0 and 2.22.0 |

## Reference

<!-- BEGIN_TF_DOCS -->
### Resources

The following resources are used by this module:

- [ovh_cloud_project_kube.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube) (resource)
- [ovh_cloud_project_kube_iprestrictions.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_iprestrictions) (resource)
- [ovh_cloud_project_kube_nodepool.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_nodepool) (resource)
- [ovh_cloud_project_kube_oidc.this](https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/cloud_project_kube_oidc) (resource)

### Required Inputs

The following input variables are required:

#### <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version)

Description: Kubernetes version, such as `1.32` or `1.33`.

Type: `string`

#### <a name="input_name"></a> [name](#input\_name)

Description: Kubernetes cluster name.

Type: `string`

#### <a name="input_region"></a> [region](#input\_region)

Description: Kubernetes cluster region, such as `GRA7`, `SBG5` or `BHS5`.

Type: `string`

#### <a name="input_service_name"></a> [service\_name](#input\_service\_name)

Description: OVH Public Cloud project service name (project ID).

Type: `string`

### Optional Inputs

The following input variables are optional (have default values):

#### <a name="input_customization_apiserver"></a> [customization\_apiserver](#input\_customization\_apiserver)

Description: Kubernetes API server customization, shaped as the provider's `customization_apiserver` block: `admissionplugins`, with the `enabled` and `disabled` plugins.

Type:

```hcl
object({
    admissionplugins = optional(object({
      enabled  = optional(list(string), [])
      disabled = optional(list(string), [])
    }), {})
  })
```

Default: `{}`

#### <a name="input_customization_kube_proxy"></a> [customization\_kube\_proxy](#input\_customization\_kube\_proxy)

Description: Kubernetes kube-proxy customization (`iptables` or `ipvs` settings).

Type:

```hcl
object({
    iptables = optional(object({
      sync_period     = optional(string)
      min_sync_period = optional(string)
    }))
    ipvs = optional(object({
      sync_period     = optional(string)
      min_sync_period = optional(string)
      scheduler       = optional(string)
      tcp_timeout     = optional(string)
      tcp_fin_timeout = optional(string)
      udp_timeout     = optional(string)
    }))
  })
```

Default: `{}`

#### <a name="input_ips"></a> [ips](#input\_ips)

Description: List of CIDR blocks to restrict Kubernetes API access. Empty list means no restriction.

Type: `list(string)`

Default: `[]`

#### <a name="input_kube_proxy_mode"></a> [kube\_proxy\_mode](#input\_kube\_proxy\_mode)

Description: Kube-proxy mode: `iptables` or `ipvs`. Changing it recreates the cluster.

Type: `string`

Default: `"iptables"`

#### <a name="input_load_balancers_subnet_id"></a> [load\_balancers\_subnet\_id](#input\_load\_balancers\_subnet\_id)

Description: The ID of the subnet for Kubernetes load balancers.

Type: `string`

Default: `null`

#### <a name="input_nodepools"></a> [nodepools](#input\_nodepools)

Description: Kubernetes node pools to create, by name: the key is the node pool's `name`, so renaming a key replaces the node pool.

Type:

```hcl
map(object({
    flavor_name        = string
    desired_nodes      = optional(number, 1)
    availability_zones = optional(list(string), [])
    max_nodes          = optional(number, 3)
    min_nodes          = optional(number, 1)
    monthly_billed     = optional(bool, false)
    anti_affinity      = optional(bool, false)
    autoscale          = optional(bool, false)

    autoscaling_scale_down_unneeded_time_seconds = optional(number)
    autoscaling_scale_down_utilization_threshold = optional(number)
    autoscaling_scale_down_unready_time_seconds  = optional(number)

    template = optional(object({
      metadata = optional(object({
        annotations = optional(map(string))
        finalizers  = optional(list(string))
        labels      = optional(map(string))
      }))
      spec = optional(object({
        unschedulable = optional(bool)
        taints = optional(list(object({
          key    = string
          effect = string
          value  = optional(string)
        })))
      }))
    }))
  }))
```

Default: `{}`

#### <a name="input_nodes_subnet_id"></a> [nodes\_subnet\_id](#input\_nodes\_subnet\_id)

Description: The ID of the subnet for Kubernetes nodes.

Type: `string`

Default: `null`

#### <a name="input_oidc"></a> [oidc](#input\_oidc)

Description: OIDC configuration for the Kubernetes cluster.

Type:

```hcl
object({
    client_id            = string
    issuer_url           = string
    oidc_username_claim  = optional(string)
    oidc_username_prefix = optional(string)
    oidc_groups_claim    = optional(list(string))
    oidc_groups_prefix   = optional(string)
    oidc_required_claim  = optional(list(string))
    oidc_signing_algs    = optional(list(string))
    oidc_ca_content      = optional(string)
  })
```

Default: `null`

#### <a name="input_plan"></a> [plan](#input\_plan)

Description: Kubernetes plan: `free` or `standard`.

Type: `string`

Default: `"free"`

#### <a name="input_private_network_configuration"></a> [private\_network\_configuration](#input\_private\_network\_configuration)

Description: Private network configuration (vRack gateway).

Type:

```hcl
object({
    default_vrack_gateway              = string
    private_network_routing_as_default = bool
  })
```

Default: `null`

#### <a name="input_private_network_id"></a> [private\_network\_id](#input\_private\_network\_id)

Description: The ID of the private network to attach to the Kubernetes cluster.

Type: `string`

Default: `null`

#### <a name="input_update_policy"></a> [update\_policy](#input\_update\_policy)

Description: Cluster update policy: `ALWAYS_UPDATE`, `MINIMAL_DOWNTIME` or `NEVER_UPDATE`.

Type: `string`

Default: `null`

### Outputs

The following outputs are exported:

#### <a name="output_kube_id"></a> [kube\_id](#output\_kube\_id)

Description: Managed Kubernetes Service ID

#### <a name="output_kube_status"></a> [kube\_status](#output\_kube\_status)

Description: Cluster status

#### <a name="output_kube_version"></a> [kube\_version](#output\_kube\_version)

Description: Kubernetes version

#### <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig)

Description: Full kubeconfig file content

#### <a name="output_kubeconfig_attributes"></a> [kubeconfig\_attributes](#output\_kubeconfig\_attributes)

Description: Kubeconfig parsed attributes

#### <a name="output_nodepools"></a> [nodepools](#output\_nodepools)

Description: Map of node pool key, as in `nodepools`, to node pool attributes
<!-- END_TF_DOCS -->

## License

[MIT](LICENSE)
