module "kubernetes" {
  source = "../../"

  service_name       = "your-ovh-project-id"
  kubernetes_name    = "my-cluster"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"

  # Private network
  kubernetes_private_network_id       = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  kubernetes_nodes_subnet_id          = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  kubernetes_load_balancers_subnet_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Single node pool with defaults
  kubernetes_nodepools = [
    {
      name        = "default"
      flavor_name = "b3-8"
    },
  ]
}

output "cluster_id" {
  value = module.kubernetes.kube_id
}

output "kubeconfig" {
  value     = module.kubernetes.kubeconfig
  sensitive = true
}
