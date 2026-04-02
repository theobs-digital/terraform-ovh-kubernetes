##############################
# Kubernetes Cluster
##############################

resource "ovh_cloud_project_kube" "this" {
  service_name             = var.service_name
  name                     = var.kubernetes_name
  version                  = var.kubernetes_version
  plan                     = var.kubernetes_plan
  region                   = var.kubernetes_region
  kube_proxy_mode          = var.kubernetes_proxy_mode
  update_policy            = var.kubernetes_update_policy
  private_network_id       = var.kubernetes_private_network_id
  nodes_subnet_id          = var.kubernetes_nodes_subnet_id
  load_balancers_subnet_id = var.kubernetes_load_balancers_subnet_id

  ###########################################
  # API Server Customization
  ###########################################

  dynamic "customization_apiserver" {
    for_each = (
      length(var.kubernetes_customization_apiserver.enabled) +
      length(var.kubernetes_customization_apiserver.disabled)
    ) > 0 ? [var.kubernetes_customization_apiserver] : []

    content {
      admissionplugins {
        enabled  = customization_apiserver.value.enabled
        disabled = customization_apiserver.value.disabled
      }
    }
  }

  ###########################################
  # Kube Proxy Customization
  ###########################################

  dynamic "customization_kube_proxy" {
    for_each = (
      var.kubernetes_customization_kube_proxy.iptables != null ||
      var.kubernetes_customization_kube_proxy.ipvs != null
    ) ? [var.kubernetes_customization_kube_proxy] : []

    content {
      dynamic "iptables" {
        for_each = customization_kube_proxy.value.iptables != null ? [customization_kube_proxy.value.iptables] : []

        content {
          sync_period     = iptables.value.sync_period
          min_sync_period = iptables.value.min_sync_period
        }
      }

      dynamic "ipvs" {
        for_each = customization_kube_proxy.value.ipvs != null ? [customization_kube_proxy.value.ipvs] : []

        content {
          sync_period     = ipvs.value.sync_period
          min_sync_period = ipvs.value.min_sync_period
          scheduler       = ipvs.value.scheduler
          tcp_timeout     = ipvs.value.tcp_timeout
          tcp_fin_timeout = ipvs.value.tcp_fin_timeout
          udp_timeout     = ipvs.value.udp_timeout
        }
      }
    }
  }

  ###########################################
  # Private Network Configuration
  ###########################################

  dynamic "private_network_configuration" {
    for_each = var.private_network_configuration != null ? [var.private_network_configuration] : []

    content {
      default_vrack_gateway              = private_network_configuration.value.default_vrack_gateway
      private_network_routing_as_default = private_network_configuration.value.private_network_routing_as_default
    }
  }
}

##############################
# OIDC
##############################

resource "ovh_cloud_project_kube_oidc" "this" {
  count = var.kubernetes_oidc != null ? 1 : 0

  service_name = var.service_name
  kube_id      = ovh_cloud_project_kube.this.id

  client_id              = var.kubernetes_oidc.client_id
  issuer_url             = var.kubernetes_oidc.issuer_url
  oidc_username_claim    = var.kubernetes_oidc.oidc_username_claim
  oidc_username_prefix   = var.kubernetes_oidc.oidc_username_prefix
  oidc_groups_claim      = var.kubernetes_oidc.oidc_groups_claim
  oidc_groups_prefix     = var.kubernetes_oidc.oidc_groups_prefix
  oidc_required_claim    = var.kubernetes_oidc.oidc_required_claim
  oidc_signing_algs      = var.kubernetes_oidc.oidc_signing_algs
  oidc_ca_content        = var.kubernetes_oidc.oidc_ca_content
}

##############################
# IP Restrictions
##############################

resource "ovh_cloud_project_kube_iprestrictions" "this" {
  count = length(var.kubernetes_ip_restrictions) > 0 ? 1 : 0

  service_name = var.service_name
  kube_id      = ovh_cloud_project_kube.this.id
  ips          = var.kubernetes_ip_restrictions
}

##############################
# Node Pools
##############################

resource "ovh_cloud_project_kube_nodepool" "this" {
  for_each = { for np in var.kubernetes_nodepools : np.name => np }

  service_name       = var.service_name
  kube_id            = ovh_cloud_project_kube.this.id
  name               = each.value.name
  flavor_name        = each.value.flavor_name
  desired_nodes      = each.value.desired_nodes
  availability_zones = each.value.availability_zones
  max_nodes          = each.value.max_nodes
  min_nodes          = each.value.min_nodes
  monthly_billed     = each.value.monthly_billed
  anti_affinity      = each.value.anti_affinity
  autoscale          = each.value.autoscale

  autoscaling_scale_down_unneeded_time_seconds = each.value.autoscaling_scale_down_unneeded_time_seconds
  autoscaling_scale_down_utilization_threshold = each.value.autoscaling_scale_down_utilization_threshold
  autoscaling_scale_down_unready_time_seconds  = each.value.autoscaling_scale_down_unready_time_seconds

  dynamic "template" {
    for_each = each.value.template != null ? [each.value.template] : []

    content {
      dynamic "metadata" {
        for_each = template.value.metadata != null ? [template.value.metadata] : []

        content {
          annotations = metadata.value.annotations
          finalizers  = metadata.value.finalizers
          labels      = metadata.value.labels
        }
      }

      dynamic "spec" {
        for_each = template.value.spec != null ? [template.value.spec] : []

        content {
          unschedulable = spec.value.unschedulable
          taints = spec.value.taints != null ? [
            for t in spec.value.taints : {
              key    = t.key
              effect = t.effect
              value  = t.value
            }
          ] : []
        }
      }
    }
  }
}
