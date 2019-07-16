# Terraform + Saltstack + Openshift

## Roadmap

* [x] **Cloud GCP**: Bation; Nat Gateway; Collocated Master & Etcd instances; Collocated Node & Infra-node instances; Separated Load-Balancer for Master and Nodes instances
* [ ] **Cloud Hetzner**: Bastion; Edge router node (gateway & load-balancer); Etcd instances; Master intances; Node instances; Infra-node instances; Wireguard Mesh VPN
* [x] **DNS Cloudflare**: Subdomain recored allocated Master instance; Dedicated record for Bastion instance; Wildcard record for Node instances

### Workflow

1. Create a Network with a primary and a secondary subnet.
2. Create Openshift Master instances allocated to the Network and attached to the primary subnet
3. Create an instance to be used a NAT Gateway 
4. Create Openshift Node instances

###  Service account

As recommanded by the Terraform's GCP [Getting Started Guide](https://www.terraform.io/docs/providers/google/getting_started.html), a dedicated service account must be created in GCP to be used by Terrafom CLI.
The service account must own the following roles for successful resources delivery.

* **Compute Administrator**: `iam.computeadmin`
* **Service account user**: `iam.serviceaccountuser`


### TL;DR

Download the GCE credential JSON file related to the `terraform` service account in the `terraform/` root directory.
Copy the `terraform.tfvars.example` file as `terraform.tfvars` and customize variables to fit your requirements.

> `terraform.tfvars` is not tracked by git in order to avoid credentials leaks.

```bash
export GOOGLE_CLOUD_KEYFILE_JSON={{path}}
cd terraform/ && \
terraform init && \
terraform plan && \
terraform apply --auto-approve
```

## Reference

* **Terrasalt**: https://github.com/bigbitbus/terrasalt
* **OKD 3.9 (Ansible)**: https://docs.okd.io/3.9/install_config/install/advanced_install.html
* **Terraform GCP**: https://registry.terraform.io/modules/GoogleCloudPlatform/managed-instance-group/google/1.1.15
