variable "service_name" {
  description = "ID of the OVHcloud Public Cloud project."
  type        = string
}

variable "private_network_id" {
  description = "ID of the private network (vRack) the cluster joins."
  type        = string
}

variable "nodes_subnet_id" {
  description = "ID of the subnet of the nodes."
  type        = string
}

variable "load_balancers_subnet_id" {
  description = "ID of the subnet of the load balancers."
  type        = string
}
