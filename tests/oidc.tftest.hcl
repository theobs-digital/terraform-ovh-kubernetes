###############################################
# Test: OIDC configuration
###############################################

mock_provider "ovh" {}

variables {
  service_name       = "test-project-id"
  kubernetes_name    = "test-cluster-oidc"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"
}

# --- OIDC enabled ---

run "oidc_enabled_plan" {
  command = plan

  variables {
    kubernetes_oidc = {
      client_id           = "my-k8s-client"
      issuer_url          = "https://auth.example.com/realms/k8s"
      oidc_groups_claim   = ["groups"]
      oidc_groups_prefix  = "oidc:"
      oidc_username_claim = "email"
    }
  }

  assert {
    condition     = length(ovh_cloud_project_kube_oidc.this) == 1
    error_message = "OIDC resource should be created when kubernetes_oidc is set"
  }

  assert {
    condition     = ovh_cloud_project_kube_oidc.this[0].client_id == "my-k8s-client"
    error_message = "OIDC client_id should match"
  }

  assert {
    condition     = ovh_cloud_project_kube_oidc.this[0].issuer_url == "https://auth.example.com/realms/k8s"
    error_message = "OIDC issuer_url should match"
  }

  assert {
    condition     = ovh_cloud_project_kube_oidc.this[0].oidc_username_claim == "email"
    error_message = "OIDC username_claim should be email"
  }
}

# --- OIDC disabled (default) ---

run "oidc_disabled_plan" {
  command = plan

  assert {
    condition     = length(ovh_cloud_project_kube_oidc.this) == 0
    error_message = "OIDC resource should not be created when kubernetes_oidc is null"
  }
}
