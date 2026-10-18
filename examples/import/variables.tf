variable "service_name" {
  description = "ID of the OVHcloud Public Cloud project."
  type        = string
}

variable "kube_id" {
  description = "ID of the existing Managed Kubernetes cluster."
  type        = string
}

variable "nodepool_id" {
  description = "ID of the existing node pool `default`."
  type        = string
}
