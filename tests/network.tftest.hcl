###############################################
# Test: Network configuration
###############################################

mock_provider "ovh" {}

variables {
  service_name       = "test-project-id"
  kubernetes_name    = "test-cluster-net"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"

  kubernetes_private_network_id       = "abcd-1234-efgh-5678"
  kubernetes_nodes_subnet_id          = "subnet-nodes-1234"
  kubernetes_load_balancers_subnet_id = "subnet-lb-1234"

  private_network_configuration = {
    default_vrack_gateway              = "10.0.0.1"
    private_network_routing_as_default = true
  }
}

run "private_network_plan" {
  command = plan

  assert {
    condition     = ovh_cloud_project_kube.this.private_network_id == "abcd-1234-efgh-5678"
    error_message = "Private network ID should be set"
  }

  assert {
    condition     = ovh_cloud_project_kube.this.nodes_subnet_id == "subnet-nodes-1234"
    error_message = "Nodes subnet ID should be set"
  }

  assert {
    condition     = ovh_cloud_project_kube.this.load_balancers_subnet_id == "subnet-lb-1234"
    error_message = "Load balancers subnet ID should be set"
  }
}

# --- No network (public cluster) ---

run "public_cluster_plan" {
  command = plan

  variables {
    kubernetes_private_network_id       = null
    kubernetes_nodes_subnet_id          = null
    kubernetes_load_balancers_subnet_id = null
    private_network_configuration       = null
  }

  assert {
    condition     = ovh_cloud_project_kube.this.private_network_id == null
    error_message = "Private network should be null for public cluster"
  }
}
