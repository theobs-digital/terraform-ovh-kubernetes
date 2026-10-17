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
