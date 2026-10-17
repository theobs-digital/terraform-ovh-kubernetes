###############################################
# Test: Input validation rules
###############################################

mock_provider "ovh" {}

# --- Cluster name too short ---

variables {
  service_name       = "test-project-id"
  name               = "abc"
  kubernetes_version = "1.32"
  region             = "GRA7"
}

run "name_too_short" {
  command = plan

  expect_failures = [
    var.name,
  ]
}

# --- Invalid version format ---

run "invalid_version_format" {
  command = plan

  variables {
    name               = "test-cluster"
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
    name               = "test-cluster"
    kubernetes_version = "1.32"
    plan               = "premium"
  }

  expect_failures = [
    var.plan,
  ]
}

# --- Invalid proxy mode ---

run "invalid_proxy_mode" {
  command = plan

  variables {
    name               = "test-cluster"
    kubernetes_version = "1.32"
    kube_proxy_mode    = "nftables"
  }

  expect_failures = [
    var.kube_proxy_mode,
  ]
}

# --- Invalid IP restriction ---

run "invalid_ip_restriction" {
  command = plan

  variables {
    name               = "test-cluster"
    kubernetes_version = "1.32"
    ips                = ["not-a-cidr"]
  }

  expect_failures = [
    var.ips,
  ]
}

# --- Duplicate node pool names ---

run "duplicate_nodepool_names" {
  command = plan

  variables {
    name               = "test-cluster"
    kubernetes_version = "1.32"
    nodepools = {
      pool-a = { name = "pool-a", flavor_name = "b3-8" }
      pool-b = { name = "pool-a", flavor_name = "b3-16" }
    }
  }

  expect_failures = [
    var.nodepools,
  ]
}

# --- Invalid update policy ---

run "invalid_update_policy" {
  command = plan

  variables {
    name               = "test-cluster"
    kubernetes_version = "1.32"
    update_policy      = "YOLO"
  }

  expect_failures = [
    var.update_policy,
  ]
}
