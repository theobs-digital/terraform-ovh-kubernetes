###############################################
# Test: Input validation rules
###############################################

mock_provider "ovh" {}

# --- Cluster name too short ---

variables {
  service_name       = "test-project-id"
  kubernetes_name    = "abc"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"
}

run "name_too_short" {
  command = plan

  expect_failures = [
    var.kubernetes_name,
  ]
}

# --- Invalid version format ---

run "invalid_version_format" {
  command = plan

  variables {
    kubernetes_name    = "test-cluster"
    kubernetes_version = "v1.32.0"
  }

  expect_failures = [
    var.kubernetes_version,
  ]
}

# --- Invalid plan ---

run "invalid_plan" {
  command = plan

  variables {
    kubernetes_name    = "test-cluster"
    kubernetes_version = "1.32"
    kubernetes_plan    = "premium"
  }

  expect_failures = [
    var.kubernetes_plan,
  ]
}

# --- Invalid proxy mode ---

run "invalid_proxy_mode" {
  command = plan

  variables {
    kubernetes_name       = "test-cluster"
    kubernetes_version    = "1.32"
    kubernetes_proxy_mode = "nftables"
  }

  expect_failures = [
    var.kubernetes_proxy_mode,
  ]
}

# --- Invalid IP restriction ---

run "invalid_ip_restriction" {
  command = plan

  variables {
    kubernetes_name            = "test-cluster"
    kubernetes_version         = "1.32"
    kubernetes_ip_restrictions = ["not-a-cidr"]
  }

  expect_failures = [
    var.kubernetes_ip_restrictions,
  ]
}

# --- Duplicate node pool names ---

run "duplicate_nodepool_names" {
  command = plan

  variables {
    kubernetes_name    = "test-cluster"
    kubernetes_version = "1.32"
    kubernetes_nodepools = [
      { name = "pool-a", flavor_name = "b3-8" },
      { name = "pool-a", flavor_name = "b3-16" },
    ]
  }

  expect_failures = [
    var.kubernetes_nodepools,
  ]
}

# --- Invalid update policy ---

run "invalid_update_policy" {
  command = plan

  variables {
    kubernetes_name          = "test-cluster"
    kubernetes_version       = "1.32"
    kubernetes_update_policy = "YOLO"
  }

  expect_failures = [
    var.kubernetes_update_policy,
  ]
}
