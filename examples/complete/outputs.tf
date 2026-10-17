output "cluster_id" {
  description = "ID of the Managed Kubernetes cluster."
  value       = module.kubernetes.kube_id
}

output "kubeconfig" {
  description = "Kubeconfig of the cluster."
  value       = module.kubernetes.kubeconfig
  sensitive   = true
}
