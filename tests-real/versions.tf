terraform {
  required_version = ">= 1.5"

  required_providers {
    ovh = {
      source = "ovh/ovh"
      # No lock file: each run takes the newest 2.x the module accepts.
      version = "~> 2.7"
    }
  }
}
