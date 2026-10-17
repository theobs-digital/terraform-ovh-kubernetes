######################################
# Cluster
######################################

output "kube_id" {
  description = "Managed Kubernetes Service ID"
  value       = ovh_cloud_project_kube.this.id
}

output "kube_version" {
  description = "Kubernetes version"
  value       = ovh_cloud_project_kube.this.version
}

output "kube_status" {
  description = "Cluster status"
  value       = ovh_cloud_project_kube.this.status
}

######################################
# Kubeconfig (Sensitive)
######################################

output "kubeconfig" {
  description = "Full kubeconfig file content"
  value       = ovh_cloud_project_kube.this.kubeconfig
  sensitive   = true
}

output "kubeconfig_attributes" {
  description = "Kubeconfig parsed attributes"
  value       = ovh_cloud_project_kube.this.kubeconfig_attributes
  sensitive   = true
}

######################################
# Node Pools
######################################

output "nodepools" {
  description = "Map of node pool name to node pool attributes"
  value = { for k, v in ovh_cloud_project_kube_nodepool.this : k => {
    id            = v.id
    name          = v.name
    flavor_name   = v.flavor_name
    desired_nodes = v.desired_nodes
    current_nodes = v.current_nodes
    max_nodes     = v.max_nodes
    min_nodes     = v.min_nodes
    status        = v.status
    autoscale     = v.autoscale
  } }
}
