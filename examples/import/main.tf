# Endpoint and credentials come from the OVH_* environment variables.
provider "ovh" {}

# The cluster as it is: an input that differs plans an update, or a
# replacement for the attributes that recreate the resource.
module "kubernetes" {
  source = "../../"

  service_name       = var.service_name
  name               = "my-cluster"
  kubernetes_version = "1.32"
  region             = "GRA7"

  oidc = {
    client_id  = "my-k8s-client"
    issuer_url = "https://auth.example.com/realms/kubernetes"
  }

  ips = ["203.0.113.0/24"]

  # The key is the node pool's current name.
  nodepools = {
    default = {
      flavor_name = "b3-8"
    }
  }
}

import {
  to = module.kubernetes.ovh_cloud_project_kube.this
  id = "${var.service_name}/${var.kube_id}"
}

import {
  to = module.kubernetes.ovh_cloud_project_kube_oidc.this[0]
  id = "${var.service_name}/${var.kube_id}"
}

import {
  to = module.kubernetes.ovh_cloud_project_kube_iprestrictions.this[0]
  id = "${var.service_name}/${var.kube_id}"
}

import {
  to = module.kubernetes.ovh_cloud_project_kube_nodepool.this["default"]
  id = "${var.service_name}/${var.kube_id}/${var.nodepool_id}"
}
