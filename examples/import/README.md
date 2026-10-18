# Import example

Brings an existing cluster under the module, with its OIDC configuration, its
IP restrictions and its node pool `default`: one `import` block per resource,
with the import ID of the provider's documentation.

| Resource | Import ID |
|---|---|
| `ovh_cloud_project_kube.this` | `<service_name>/<kube_id>` |
| `ovh_cloud_project_kube_oidc.this[0]` | `<service_name>/<kube_id>` |
| `ovh_cloud_project_kube_iprestrictions.this[0]` | `<service_name>/<kube_id>` |
| `ovh_cloud_project_kube_nodepool.this["<name>"]` | `<service_name>/<kube_id>/<node pool ID>` |

First write each input in `main.tf` as the cluster has it: an input left at
the module's default, such as `kube_proxy_mode = "iptables"` on a cluster in
`ipvs` mode, plans a replacement, which deletes the cluster. Key each node
pool by its current name. When the cluster has no OIDC configuration or no
IP restrictions, drop their `import` block, along with `oidc` or `ips` in the
module call.

```bash
export OVH_ENDPOINT=ovh-eu OVH_CLIENT_ID=... OVH_CLIENT_SECRET=...
terraform init
terraform plan \
  -var service_name=<Public Cloud project ID> \
  -var kube_id=<cluster ID> \
  -var nodepool_id=<node pool ID>
```

Apply only a plan that imports every object and destroys none: look for
`must be replaced` in it. Once applied, the `import` blocks can go. They need
Terraform 1.6 or later, the first that takes variables in their `id`.
