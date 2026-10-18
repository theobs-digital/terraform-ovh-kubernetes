variable "service_name" {
  description = "ID of the test Public Cloud project."
  type        = string
}

variable "region" {
  description = "A region of the test project that offers Managed Kubernetes, such as `GRA7`."
  type        = string
}

variable "kubernetes_version" {
  description = "A minor release of Kubernetes that MKS offers, such as `1.32`."
  type        = string
}
