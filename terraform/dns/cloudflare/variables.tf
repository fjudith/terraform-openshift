variable "host_count" {}

variable "email" {}

variable "token" {}

variable "domain" {}

variable "subdomain" {}

variable "hostnames" {
  type = "list"
}

variable "public_ips" {
  type = "list"
}

variable "bastion_host" {
  default = "bastion"
}
variable "bastion_create" {
  default = false
}

variable "bastion_ip" {
  default = ["1.2.3.4"]
}