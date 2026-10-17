variable "service_name" {
  description = "OVH Public Cloud project service name (project ID)."
  type        = string
}

variable "name" {
  description = "Kubernetes cluster name."
  type        = string

  # The OVHcloud console allows 5 to 63 characters; provider 2.22 checks nothing.
  validation {
    condition     = length(var.name) >= 5 && length(var.name) <= 63
    error_message = "name must be between 5 and 63 characters."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version, such as `1.32` or `1.33`."
  type        = string

  # Provider 2.22 takes any string, while MKS expects a minor release such as 1.32.
  validation {
    condition     = can(regex("^\\d+\\.\\d+$", var.kubernetes_version))
    error_message = "kubernetes_version must be in the format X.Y (e.g. 1.32)."
  }
}

variable "plan" {
  description = "Kubernetes plan: `free` or `standard`."
  type        = string
  # Free unless asked, whatever OVHcloud's default becomes.
  default = "free"
}

variable "region" {
  description = "Kubernetes cluster region, such as `GRA7`, `SBG5` or `BHS5`."
  type        = string
}

variable "kube_proxy_mode" {
  description = "Kube-proxy mode: `iptables` or `ipvs`. Changing it recreates the cluster."
  type        = string
  # Iptables unless asked, whatever OVHcloud's default becomes: the mode only
  # changes by recreating the cluster.
  default = "iptables"
}

variable "update_policy" {
  description = "Cluster update policy: `ALWAYS_UPDATE`, `MINIMAL_DOWNTIME` or `NEVER_UPDATE`."
  type        = string
  default     = null

  # Provider 2.22 lets any value through: the API refuses it only at apply.
  validation {
    condition     = var.update_policy == null ? true : contains(["ALWAYS_UPDATE", "MINIMAL_DOWNTIME", "NEVER_UPDATE"], var.update_policy)
    error_message = "update_policy must be one of: ALWAYS_UPDATE, MINIMAL_DOWNTIME, NEVER_UPDATE."
  }
}

variable "private_network_id" {
  description = "The ID of the private network to attach to the Kubernetes cluster."
  type        = string
  default     = null
}

variable "nodes_subnet_id" {
  description = "The ID of the subnet for Kubernetes nodes."
  type        = string
  default     = null
}

variable "load_balancers_subnet_id" {
  description = "The ID of the subnet for Kubernetes load balancers."
  type        = string
  default     = null
}

variable "private_network_configuration" {
  description = "Private network configuration (vRack gateway)."
  type = object({
    default_vrack_gateway              = string
    private_network_routing_as_default = bool
  })
  default = null
}

variable "customization_apiserver" {
  description = "Kubernetes API server customization, shaped as the provider's `customization_apiserver` block: `admissionplugins`, with the `enabled` and `disabled` plugins."
  type = object({
    admissionplugins = optional(object({
      enabled  = optional(list(string), [])
      disabled = optional(list(string), [])
    }), {})
  })
  # Empty lists: no customization block.
  default = {}
}

variable "customization_kube_proxy" {
  description = "Kubernetes kube-proxy customization (`iptables` or `ipvs` settings)."
  type = object({
    iptables = optional(object({
      sync_period     = optional(string)
      min_sync_period = optional(string)
    }))
    ipvs = optional(object({
      sync_period     = optional(string)
      min_sync_period = optional(string)
      scheduler       = optional(string)
      tcp_timeout     = optional(string)
      tcp_fin_timeout = optional(string)
      udp_timeout     = optional(string)
    }))
  })
  # No iptables nor ipvs settings: no customization block.
  default = {}
}

variable "oidc" {
  description = "OIDC configuration for the Kubernetes cluster."
  type = object({
    client_id            = string
    issuer_url           = string
    oidc_username_claim  = optional(string)
    oidc_username_prefix = optional(string)
    oidc_groups_claim    = optional(list(string))
    oidc_groups_prefix   = optional(string)
    oidc_required_claim  = optional(list(string))
    oidc_signing_algs    = optional(list(string))
    oidc_ca_content      = optional(string)
  })
  default = null
}

variable "ips" {
  description = "List of CIDR blocks to restrict Kubernetes API access. Empty list means no restriction."
  type        = list(string)
  default     = []

  # Provider 2.22 lets any string through, and the restrictions come after the
  # cluster: a bad CIDR would leave it open until the next apply.
  validation {
    condition     = length(var.ips) == 0 || alltrue([for ip in var.ips : can(cidrnetmask(ip))])
    error_message = "Each item in ips must be a valid IPv4 CIDR block (e.g. 10.0.0.0/8)."
  }
}

variable "nodepools" {
  description = "Kubernetes node pools to create, by name: the key is the node pool's `name`, so renaming a key replaces the node pool."
  type = map(object({
    flavor_name        = string
    desired_nodes      = optional(number, 1)
    availability_zones = optional(list(string), [])
    max_nodes          = optional(number, 3)
    min_nodes          = optional(number, 1)
    monthly_billed     = optional(bool, false)
    anti_affinity      = optional(bool, false)
    autoscale          = optional(bool, false)

    autoscaling_scale_down_unneeded_time_seconds = optional(number)
    autoscaling_scale_down_utilization_threshold = optional(number)
    autoscaling_scale_down_unready_time_seconds  = optional(number)

    template = optional(object({
      metadata = optional(object({
        annotations = optional(map(string))
        finalizers  = optional(list(string))
        labels      = optional(map(string))
      }))
      spec = optional(object({
        unschedulable = optional(bool)
        taints = optional(list(object({
          key    = string
          effect = string
          value  = optional(string)
        })))
      }))
    }))
  }))
  default = {}
}
