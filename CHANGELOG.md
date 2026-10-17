# Changelog

All notable changes to this module are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this module adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.1] - 2026-10-17

### Fixed

- Provider `ovh/ovh` `~> 2.7`, was `>= 1.0, < 2.0`: the `plan` attribute of `ovh_cloud_project_kube` exists only from 2.7.0, so 1.0.0 validated with no provider release it allowed
- Terraform 1.5 to 1.11: a call without `kubernetes_update_policy` failed, because `||` evaluated `contains()` on `null` too; Terraform evaluates only one side since 1.12

### Added

- `LICENSE` (MIT), `.tflint.hcl`, and the workflow `Checks`: the pre-commit hooks and the mock tests on every pull request and push to `main`, and a validation with Terraform 1.5.7 and provider 2.7.0, the bottom of the requirements
- `versions.tf`, `variables.tf`, `outputs.tf` and a README in each example, which configures the provider

### Changed

- README: a Requirements table with the releases the module was checked with, and the module taken from `github.com/theobs-digital`
- Example `basic`: a public cluster, as in the README
- pre-commit-terraform v1.109.2; the terraform-docs reference lists types as HCL blocks
- `output.tf` renamed `outputs.tf`; `provider.tf`, `locals.tf` and `docs/header.md` removed: they held only comments, or were never read

## [1.0.0] - 2026-04-02

### Added

- Kubernetes MKS cluster creation on OVHcloud Public Cloud
- Multiple node pools with autoscaling, taints, labels, and anti-affinity
- Private network (vRack) support with gateway configuration
- Public cluster support (no network required)
- API server customization (admission plugins)
- Kube-proxy customization (iptables/ipvs)
- IP restrictions on Kubernetes API
- Configurable update policy (ALWAYS_UPDATE, MINIMAL_DOWNTIME, NEVER_UPDATE)
- Input validations (name length, version format, plan, proxy mode, CIDR, unique node pool names)
- Native Terraform tests (`terraform test`) with mock provider
- Examples: basic and complete

[Unreleased]: https://github.com/theobs-digital/terraform-ovh-kubernetes/compare/v1.0.1...main
[1.0.1]: https://github.com/theobs-digital/terraform-ovh-kubernetes/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/theobs-digital/terraform-ovh-kubernetes/releases/tag/v1.0.0
