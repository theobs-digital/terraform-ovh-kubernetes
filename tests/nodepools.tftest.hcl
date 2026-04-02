###############################################
# Test: Node pools configuration
###############################################

mock_provider "ovh" {}

variables {
  service_name       = "test-project-id"
  kubernetes_name    = "test-cluster-np"
  kubernetes_version = "1.32"
  kubernetes_region  = "GRA7"

  kubernetes_nodepools = [
    {
      name        = "general"
      flavor_name = "b3-8"
    },
    {
      name          = "workers"
      flavor_name   = "b3-16"
      desired_nodes = 2
      max_nodes     = 10
      min_nodes     = 2
      autoscale     = true
      template = {
        metadata = {
          annotations = {}
          finalizers  = []
          labels = {
            "role" = "worker"
          }
        }
        spec = {
          unschedulable = false
          taints = [
            {
              key    = "dedicated"
              effect = "NoSchedule"
              value  = "workers"
            }
          ]
        }
      }
    },
  ]
}

run "nodepools_plan" {
  command = plan

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["general"].name == "general"
    error_message = "General node pool should exist"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["general"].flavor_name == "b3-8"
    error_message = "General pool flavor should be b3-8"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["general"].desired_nodes == 1
    error_message = "General pool should default to 1 desired node"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["general"].max_nodes == 3
    error_message = "General pool should default to 3 max nodes"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["general"].min_nodes == 1
    error_message = "General pool should default to 1 min node"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["general"].autoscale == false
    error_message = "General pool autoscale should default to false"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["workers"].name == "workers"
    error_message = "Workers node pool should exist"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["workers"].desired_nodes == 2
    error_message = "Workers pool should have 2 desired nodes"
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["workers"].autoscale == true
    error_message = "Workers pool should have autoscale enabled"
  }
}
