module "network" {
    source = "./provider/gcp/terraform-google-network"
    #version = "0.8.0"

    project_id = "${var.gcp_project}"
    network_name = "${var.resource_prefix}-network"
    subnets = [
        {
            subnet_name = "${var.resource_prefix}-subnet-01"
            subnet_ip   = "${var.primary_subnet_cidr}"
            subnet_region = "${var.gcp_region}"
        },
        {
            subnet_name = "${var.resource_prefix}-subnet-02"
            subnet_ip   = "${var.secondary_subnet_cidr}"
            subnet_region = "${var.gcp_region}"
            subnet_private_access = "true"
            subnet_flow_logs = "true"
        },
    ]

    secondary_ranges = {
        "${var.resource_prefix}-subnet-01" = []
        "${var.resource_prefix}-subnet-02" = []
    }
}


module "gateway" {
  source = "./provider/gcp/terraform-google-nat-gateway"
  # version = "1.2.2"

  name         = "${var.resource_prefix}-"
  project      = "${var.gcp_project}"
  region       = "${var.gcp_region}"
  network      = "${module.network.network_name}"
  subnetwork   = "${element(module.network.subnets_names, 0)}"
  machine_type = "${var.gce_gateway_type}"
}


module "master-loadbalancer" {
  source = "./provider/gcp/terraform-google-lb-target-pool"

  project           = "${var.gcp_project}"
  region            = "${var.gcp_region}"
  name              = "${var.resource_prefix}-master"
  network           = "${module.network.network_name}"
  service_port_name  = ["${var.resource_prefix}-master-api"]
  service_port       = ["443"]
  session_affinity  = "CLIENT_IP"
  target_tags       = ["${var.resource_prefix}-masters"]
  instances         = ["${module.master.instance_link}"]
}

module "node-loadbalancer" {
  source = "./provider/gcp/terraform-google-lb-target-pool"

  project           = "${var.gcp_project}"
  region            = "${var.gcp_region}"
  name              = "${var.resource_prefix}"
  network           = "${module.network.network_name}"
  service_port_name = ["${var.resource_prefix}-node-http","${var.resource_prefix}-node-https"]
  service_port      = ["80","443"]
  session_affinity  = "CLIENT_IP"
  target_tags       = ["${var.resource_prefix}-nodes"]
  instances         = ["${module.node.instance_link}"]
}

module "master" {
  source       = "./provider/gcp/gce-master"

  bastion_host = "${module.bastion.external_ip}"
  ssh_user     = "admin"

  project                = "${var.gcp_project}"
  region                 = "${var.gcp_region}"
  cluster_zones          = "${var.gcp_cluster_zones}"
  name                   = "${var.resource_prefix}-master"
  instance_count         = "${var.master_count}"
  service_port_name      = "${var.resource_prefix}-api-https"
  service_port           = "${var.master_service_port}"
  target_tags            = ["${var.resource_prefix}-nat-${var.gcp_region}", "${var.resource_prefix}-masters"]
  http_health_check      = false
  service_account_scopes = ["${var.gcp_service_account_scopes}"]
  network                = "${module.network.network_name}"
  subnetwork             = "${element(module.network.subnets_names, 0)}"
  access_config          = ["${var.gcp_access_config}"]
  can_ip_forward         = true
  machine_type           = "${var.gce_master_type}"
  compute_image          = "${var.gce_image_project}/${var.gce_image_family}"
  startup_script         = "${module.salt-minion-master.centos}"
  etcd_disk_size_gb       = "10"
  containers_disk_size_gb = "30"
  local_disk_size_gb      = "10"

  metadata = {
    "owner" = "${var.owner}"

    "ssh-keys" = "${file("${var.ssh_public_key}")}"
  }
}


module "node" {
  source = "./provider/gcp/gce-node"

  bastion_host = "${module.bastion.external_ip}"
  ssh_user     = "admin"

  project                = "${var.gcp_project}"
  region                 = "${var.gcp_region}"
  cluster_zones          = "${var.gcp_cluster_zones}"
  name                   = "${var.resource_prefix}-node"
  instance_count         = "${var.node_count}"
  service_port_name      = "${var.resource_prefix}-null"
  service_port           = "65535"
  target_tags            = ["${var.resource_prefix}-nat-${var.gcp_region}", "${var.resource_prefix}-node"]
  http_health_check      = false
  service_account_scopes = ["${var.gcp_service_account_scopes}"]
  network                = "${module.network.network_name}"
  subnetwork             = "${element(module.network.subnets_names, 0)}"
  access_config          = ["${var.gcp_access_config}"]
  can_ip_forward         = true
  machine_type           = "${var.gce_node_type}"
  compute_image          = "${var.gce_image_project}/${var.gce_image_family}"
  startup_script         = "${module.salt-minion-node.centos}"
  containers_disk_size_gb = "30"
  local_disk_size_gb      = "10"

  metadata = {
    "owner" = "${var.owner}"

    "ssh-keys" = "${file("${var.ssh_public_key}")}"
  }
}

module "bastion" {
  source = "./provider/gcp/gce-bastion"

  ssh_public_key    = "${var.ssh_public_key}"
  bastion_type      = "${var.gce_bastion_type}"
  region            = "${var.gcp_region}"
  subnet_cidr       = "${var.primary_subnet_cidr}"
  bastion_image     = "${var.gce_image_project}/${var.gce_image_family}"
  res_prefix        = "${var.resource_prefix}"
  project           = "${var.gcp_project}"
  owner             = "${var.owner}"
  cluster_zones     = "${var.gcp_cluster_zones}"
  network           = "${module.network.network_name}"
  subnetwork        = "${element(module.network.subnets_self_links, 0)}"
  bastion_create    = true
  startup_script    = "${module.salt-master.centos}"
}

module "dns" {
  source = "./dns/cloudflare"

  host_count      = 1
  email           = "${var.cloudflare_email}"
  token           = "${var.cloudflare_token}"
  domain          = "${var.domain}"
  subdomain       = "${var.subdomain}"
  master_lb_ip    = "${list(module.master-loadbalancer.external_ip)}"
  node_lb_ip      = "${list(module.node-loadbalancer.external_ip)}"
  hostnames       = "${list("${var.resource_prefix}")}"
  bastion_create  = true
  bastion_host    = "bastion"
  bastion_ip      = "${list(module.bastion.external_ip)}"
}

module "salt-master" {
  source = "./configuration-management/salt-master"

  role    = "bastion"
}

module "salt-minion-master" {
  source = "./configuration-management/salt-minion"

  role    = "master"
  salt_master = "${module.bastion.internal_ip}"
}
module "salt-minion-node" {
  source = "./configuration-management/salt-minion"

  role    = "node"
  salt_master = "${module.bastion.internal_ip}"
}

# module "os_tuning" {
#   source = "./os-tuning/centos"

#   machine_count = "${length(concat(module.bastion.external_ip, module.gateway.external_ip, module.master.network_ip, module.node.network_ip))}"
#   ssh_user = "centos"
#   bastion_host = "${module.bastion.external_ip}"
#   ssh_private_key = "${var.ssh_private_key}"
#   connections = "${concat(module.bastion.external_ip, module.gateway.external_ip, module.master.network_ip, module.node.network_ip)}"
# }

