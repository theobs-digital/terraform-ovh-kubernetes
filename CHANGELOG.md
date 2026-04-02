# Changelog

All notable changes to this module will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

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
