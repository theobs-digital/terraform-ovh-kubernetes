# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "kubernetes" {
  source = "../../"

  service_name       = var.service_name
  name               = "my-cluster-prod"
  kubernetes_version = "1.32"
  plan               = "standard"
  region             = "GRA7"

  # Network
  private_network_id       = var.private_network_id
  nodes_subnet_id          = var.nodes_subnet_id
  load_balancers_subnet_id = var.load_balancers_subnet_id

  private_network_configuration = {
    default_vrack_gateway              = "10.0.0.1"
    private_network_routing_as_default = true
  }

  # Update policy
  update_policy = "MINIMAL_DOWNTIME"

  # API Server customization
  customization_apiserver = {
    admissionplugins = {
      enabled  = ["NodeRestriction"]
      disabled = ["AlwaysPullImages"]
    }
  }

  # OIDC authentication
  oidc = {
    client_id           = "my-k8s-client"
    issuer_url          = "https://auth.example.com/realms/kubernetes"
    oidc_groups_claim   = ["groups"]
    oidc_groups_prefix  = "oidc:"
    oidc_username_claim = "email"
  }

  # IP Restrictions
  ips = [
    "203.0.113.0/24",
    "198.51.100.0/24",
  ]

  # Node Pools
  nodepools = {
    general = {
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
    }
    gpu-workers = {
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
    }
  }
}
