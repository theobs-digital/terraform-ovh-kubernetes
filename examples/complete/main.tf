# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "kubernetes" {
  source = "../../"

  service_name       = var.service_name
  kubernetes_name    = "my-cluster-prod"
  kubernetes_version = "1.32"
  kubernetes_plan    = "standard"
  kubernetes_region  = "GRA7"

  # Network
  kubernetes_private_network_id       = var.private_network_id
  kubernetes_nodes_subnet_id          = var.nodes_subnet_id
  kubernetes_load_balancers_subnet_id = var.load_balancers_subnet_id

  private_network_configuration = {
    default_vrack_gateway              = "10.0.0.1"
    private_network_routing_as_default = true
  }

  # Update policy
  kubernetes_update_policy = "MINIMAL_DOWNTIME"

  # API Server customization
  kubernetes_customization_apiserver = {
    enabled  = ["NodeRestriction"]
    disabled = ["AlwaysPullImages"]
  }

  # OIDC authentication
  kubernetes_oidc = {
    client_id           = "my-k8s-client"
    issuer_url          = "https://auth.example.com/realms/kubernetes"
    oidc_groups_claim   = ["groups"]
    oidc_groups_prefix  = "oidc:"
    oidc_username_claim = "email"
  }

  # IP Restrictions
  kubernetes_ip_restrictions = [
    "203.0.113.0/24",
    "198.51.100.0/24",
  ]

  # Node Pools
  kubernetes_nodepools = [
    {
      name          = "general"
      flavor_name   = "b3-8"
      desired_nodes = 3
      max_nodes     = 5
      min_nodes     = 1
      autoscale     = true

      autoscaling_scale_down_unneeded_time_seconds = 600

      template = {
        metadata = {
          labels = {
            "workload" = "general"
          }
        }
      }
    },
    {
      name           = "gpu-workers"
      flavor_name    = "t2-45"
      desired_nodes  = 1
      max_nodes      = 3
      min_nodes      = 0
      autoscale      = true
      monthly_billed = true

      template = {
        metadata = {
          labels = {
            "workload" = "gpu"
          }
        }
        spec = {
          taints = [
            {
              key    = "nvidia.com/gpu"
              effect = "NoSchedule"
              value  = "true"
            }
          ]
        }
      }
    },
  ]
}
