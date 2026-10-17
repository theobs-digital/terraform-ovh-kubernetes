# Basic example

Creates the public Managed Kubernetes cluster `my-cluster` in `GRA7`, with one
node pool of `b3-8` nodes. The module defaults apply to everything else: plan
`free`, kube-proxy in `iptables` mode, no private network, OIDC or IP
restriction.

```bash
export OVH_ENDPOINT=ovh-eu OVH_CLIENT_ID=... OVH_CLIENT_SECRET=...
terraform init
terraform apply -var service_name=<Public Cloud project ID>
```

The provider also takes `OVH_APPLICATION_KEY`, `OVH_APPLICATION_SECRET` and
`OVH_CONSUMER_KEY` instead of the OAuth2 client.
