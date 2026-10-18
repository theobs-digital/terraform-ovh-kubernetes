terraform {
  # 1.6: the first that takes variables in the id of an import block.
  required_version = ">= 1.6"

  required_providers {
    ovh = {
      source  = "ovh/ovh"
      version = "~> 2.7"
    }
  }
}
