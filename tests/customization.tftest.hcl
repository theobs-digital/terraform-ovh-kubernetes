###############################################
# Test: API server customization
###############################################

mock_provider "ovh" {}

variables {
  service_name       = "test-project-id"
  name               = "test-cluster-api"
  kubernetes_version = "1.32"
  region             = "GRA7"

  customization_apiserver = {
    admissionplugins = {
      enabled  = ["NodeRestriction"]
      disabled = ["AlwaysPullImages"]
    }
  }
}

run "admission_plugins_plan" {
  command = plan

  assert {
    condition     = one(one(ovh_cloud_project_kube.this.customization_apiserver).admissionplugins).enabled == tolist(["NodeRestriction"])
    error_message = "Enabled admission plugins should be passed to the provider"
  }

  assert {
    condition     = one(one(ovh_cloud_project_kube.this.customization_apiserver).admissionplugins).disabled == tolist(["AlwaysPullImages"])
    error_message = "Disabled admission plugins should be passed to the provider"
  }
}
