# Real API, not a mock: apply this configuration, plan it again, which must
# show no change, and destroy it. A Free cluster named tf-test-ci-kubernetes,
# with one b3-8 node, OIDC and IP restrictions; the node is billed while it
# exists.
#
#   export OVH_ENDPOINT=ovh-eu OVH_APPLICATION_KEY=... OVH_APPLICATION_SECRET=... OVH_CONSUMER_KEY=...
#   export TF_VAR_service_name=... TF_VAR_region=GRA7 TF_VAR_kubernetes_version=1.32
#   terraform init
#   terraform apply
#   terraform plan -detailed-exitcode
#   terraform destroy
provider "ovh" {}

module "kubernetes" {
  source = "../"

  service_name       = var.service_name
  name               = "tf-test-ci-kubernetes"
  kubernetes_version = var.kubernetes_version
  region             = var.region

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
