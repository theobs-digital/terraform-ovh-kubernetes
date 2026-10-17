# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

module "kubernetes" {
  source = "../../"

  service_name       = var.service_name
  kubernetes_name    = "my-cluster"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"

  # Single node pool with defaults
  kubernetes_nodepools = [
    {
      name        = "default"
      flavor_name = "b3-8"
    },
  ]
}
