output "kube_id" {
  description = "ID of the test cluster, to find it if a run leaves it behind."
  value       = module.kubernetes.kube_id
}

output "nodepool_status" {
  description = "Status of the test node pool, `READY` once the apply is done."
  value       = module.kubernetes.nodepools["tf-test-ci"].status

  # The provider ends the create of a node pool on ERROR as on READY.
  precondition {
    condition     = module.kubernetes.nodepools["tf-test-ci"].status == "READY"
    error_message = "The node pool must be READY."
  }
}
