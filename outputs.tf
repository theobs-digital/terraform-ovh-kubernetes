output "kube_id" {
  description = "ID of the Managed Kubernetes Service cluster, for the resources and API calls that act on it."
  value       = ovh_cloud_project_kube.this.id
}

output "kube_version" {
  description = "Kubernetes version of the cluster, for the clients that must match it, such as `kubectl`."
  value       = ovh_cloud_project_kube.this.version
}

output "kube_status" {
  description = "Status of the cluster, normally `READY`, to check that it is up."
  value       = ovh_cloud_project_kube.this.status
}

output "kubeconfig" {
  description = "Full content of the kubeconfig file, to connect `kubectl` and the other Kubernetes clients to the cluster."
  value       = ovh_cloud_project_kube.this.kubeconfig
  sensitive   = true
}

output "kubeconfig_attributes" {
  description = "Parsed attributes of the kubeconfig, a list of one object: `host`, and the base64-encoded `cluster_ca_certificate`, `client_certificate` and `client_key`, to configure a provider such as `kubernetes` or `helm`."
  value       = ovh_cloud_project_kube.this.kubeconfig_attributes
  sensitive   = true
}

output "nodepools" {
  description = "Attributes of each node pool, by key of `nodepools`: `id`, `name`, `flavor_name`, `desired_nodes`, `current_nodes`, `max_nodes`, `min_nodes`, `status` and `autoscale`, to follow its size and status."
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
