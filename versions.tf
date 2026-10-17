terraform {
  required_version = ">= 1.5"

  required_providers {
    ovh = {
      source = "ovh/ovh"
      # 2.7.0: the plan attribute of ovh_cloud_project_kube.
      version = "~> 2.7"
    }
  }
}
