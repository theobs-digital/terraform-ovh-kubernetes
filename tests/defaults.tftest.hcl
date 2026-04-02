###############################################
# Test: Minimal configuration with defaults
###############################################

mock_provider "ovh" {}

variables {
  service_name       = "test-project-id"
  kubernetes_name    = "test-cluster"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"
}

run "minimal_config_plan" {
  command = plan

  assert {
    condition     = ovh_cloud_project_kube.this.name == "test-cluster"
    error_message = "Cluster name should be test-cluster"
  }

  assert {
    condition     = ovh_cloud_project_kube.this.version == "1.32"
    error_message = "Cluster version should be 1.32"
  }

  assert {
    condition     = ovh_cloud_project_kube.this.region == "GRA7"
    error_message = "Cluster region should be GRA7"
  }

  assert {
    condition     = ovh_cloud_project_kube.this.plan == "free"
    error_message = "Default plan should be free"
  }

  assert {
    condition     = ovh_cloud_project_kube.this.kube_proxy_mode == "iptables"
    error_message = "Default proxy mode should be iptables"
  }
}
