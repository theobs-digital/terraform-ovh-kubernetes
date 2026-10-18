# Real API, not a mock: a Free cluster named tf-test-ci-kubernetes, with one
# b3-8 node, OIDC and IP restrictions, created then destroyed. The node is
# billed while the test runs.
#
#   export OVH_ENDPOINT=ovh-eu OVH_APPLICATION_KEY=... OVH_APPLICATION_SECRET=... OVH_CONSUMER_KEY=...
#   export TF_VAR_service_name=... TF_VAR_region=GRA7 TF_VAR_kubernetes_version=1.32
#   terraform test -test-directory=tests-real
provider "ovh" {}

variables {
  name = "tf-test-ci-kubernetes"

  oidc = {
    client_id  = "tf-test-ci"
    issuer_url = "https://accounts.google.com"
  }

  # Every address: the test checks the resource, not the restriction.
  ips = ["0.0.0.0/0"]

  nodepools = {
    tf-test-ci = { flavor_name = "b3-8" }
  }
}

run "create" {
  assert {
    condition     = output.kube_status == "READY"
    error_message = "The cluster must be ready."
  }

  assert {
    condition     = output.nodepools["tf-test-ci"].flavor_name == "b3-8"
    error_message = "The node pool must be created with its flavor."
  }
}

# A plan that replaces an object leaves its ID unknown, which fails the run:
# this catches a replacement, not an update in place.
run "no_replacement" {
  command = plan

  assert {
    condition     = ovh_cloud_project_kube.this.id == run.create.kube_id
    error_message = "A second plan must keep the cluster."
  }

  assert {
    condition     = ovh_cloud_project_kube_nodepool.this["tf-test-ci"].id == run.create.nodepools["tf-test-ci"].id
    error_message = "A second plan must keep the node pool."
  }

  assert {
    condition     = ovh_cloud_project_kube_oidc.this[0].id != null && ovh_cloud_project_kube_iprestrictions.this[0].id != null
    error_message = "A second plan must keep the OIDC configuration and the IP restrictions."
  }
}
