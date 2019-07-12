provider "cloudflare" {
  email = "${var.email}"
  token = "${var.token}"
}

resource "cloudflare_record" "domain" {
  domain  = "${var.domain}"
  name    = "${var.subdomain}"
  value   = "${element(var.public_ips, 0)}"
  type    = "A"
  proxied = true
}

resource "cloudflare_record" "hosts" {
  count = "${var.host_count}"

  domain  = "${var.domain}"
  name    = "${element(var.hostnames, count.index)}.${var.subdomain}.${var.domain}"
  value   = "${element(var.public_ips, count.index)}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "bastion" {
  count   = "${var.bastion_create ? 1 : 0}"

  domain  = "${var.domain}"
  name    = "${var.bastion_host}.${var.subdomain}.${var.domain}"
  value   = "${element(var.bastion_ip, count.index)}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "wildcard" {
  depends_on = ["cloudflare_record.domain"]

  domain  = "${var.domain}"
  name    = "*.${var.subdomain}.${var.domain}"
  value   = "${element(var.public_ips, 0)}"
  type    = "A"
  proxied = false
}