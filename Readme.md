# Simple Talos Cluster

First set envs:

```
export CONTROL_PLANE_IP=1.2.3.4
export WORKER_IP=5.6.7.8
```

# Variables

Edit variables.tf 
1. Set cluster_name
2. Set which Proxmox node you want to deploy to
3. Go to https://factory.talos.dev/ and click through the wizard to get your schematic ID
4. Fill in your Proxmox credentials
5. Set the number of control plane and worker nodes
6. Set default gateway and IPs to be used

# Check & Run

```
Run "tofu validate" to find typos
Run "tofu plan" to see what is going to happen
Run "tofu apply -auto-approve" to apply and skip approvals
```

# Last things

```
Run "tofu output -raw kubeconfig > kubeconfig"
Run "tofu output -raw talosconfig > talosconfig"

export TALOSCONFIG="talosconfig"

talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
```

# Test

```
kubectl get nodes --kubeconfig=kubeconfig
```
