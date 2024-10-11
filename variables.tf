variable "cluster_name" {
  type    = string
  default = "homelab"
}

variable "node_name" {
  type    = string
  default = "pve-4"
}

variable "schematic_id" {
  type    = string
  default = "xxx"
}

variable "PROXMOX_USERNAME" {
  description = "User name used to login proxmox"
  type        = string
  default     = "root"
}

variable "PROXMOX_PASSWORD" {
  description = "Password used to login proxmox"
  type        = string
  default     = "xxx"
}

variable "control_plane_count" {
  description = "Number of Kubernetes control plane nodes"
  type        = number
  default     = 2
}

variable "worker_count" {
  description = "Number of Kubernetes worker nodes"
  type        = number
  default     = 6
}
variable "default_gateway" {
  type    = string
  default = "192.168.0.1"
}


variable "control_plane_ips" {
  description = "List of static IPs for control plane nodes"
  type        = list(string)
  default     = ["192.168.0.50", "192.168.0.51"]
}

variable "worker_ips" {
  description = "List of static IPs for worker nodes"
  type        = list(string)
  default     = ["192.168.0.55", "192.168.0.56", "192.168.0.57", "192.168.0.58", "192.168.0.59", "192.168.0.60"]
}
