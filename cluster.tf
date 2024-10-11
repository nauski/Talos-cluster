resource "talos_machine_secrets" "machine_secrets" {}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = var.control_plane_ips
}

data "talos_machine_configuration" "machineconfig_cp" {
  for_each         = toset(var.control_plane_ips)
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${each.value}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  depends_on                  = [ proxmox_virtual_environment_vm.control_planes ]
  for_each                    = data.talos_machine_configuration.machineconfig_cp
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = each.value.machine_configuration
  node                        = each.key
}

data "talos_machine_configuration" "machineconfig_worker" {
  count            = length(var.worker_ips)
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.control_plane_ips[0]}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  count                       = length(var.worker_ips)
  depends_on                  = [ proxmox_virtual_environment_vm.workers ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker[count.index].machine_configuration
  node                        = var.worker_ips[count.index]
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = element(var.control_plane_ips, 0)
}

data "talos_cluster_health" "health" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply ]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = var.control_plane_ips
  worker_nodes         = var.worker_ips
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = element(var.control_plane_ips, 0)
}

output "talosconfig" {
  value = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}
