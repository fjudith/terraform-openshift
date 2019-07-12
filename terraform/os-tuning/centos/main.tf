resource "null_resource" "systctl" {
    count = "${var.machine_count}"

    connection {
        type = "ssh"
        host = "${element(var.connections, count.index)}"
        user = "${var.ssh_user}"
        private_key         = "${file(var.ssh_private_key)}"
        agent               = false
        bastion_host        = "${var.bastion_host}"
        bastion_user        = "${var.ssh_user}"
        bastion_private_key = "${file(var.ssh_private_key)}"
        timeout             = "1m"
    }

    provisioner "remote-exec" {
    inline = [
      "modprobe br_netfilter",
      "echo 'net.ipv4.ip_forward=1' | tee -a /etc/sysctl.conf",
      "echo 'net.ipv6.conf.all.forwarding=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-arptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables=1' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-pppoe-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-filter-vlan-tagged=0' | tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-pass-vlan-input-dev=0' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo '*    soft nofile 1048576' | tee -a /etc/security/limits.conf", 
      "echo '*    hard nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root soft nofile 1048576' | tee -a /etc/security/limits.conf",
      "echo 'root hard nofile 1048576' | tee -a /etc/security/limits.conf",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'session required pam_limits.so' | tee -a  /etc/pam.d/common-session",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "modprobe ip_conntrack",
      "echo '1024 65535' | tee -a /proc/sys/net/ipv4/ip_local_port_range",
      "echo 'net.ipv4.tcp_tw_reuse=1' | tee -a /etc/sysctl.conf",
      "echo 'net.netfilter.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.nf_conntrack_max=1048576' | tee -a /etc/sysctl.conf",
      "echo 'net.core.somaxconn=1048576' | tee -a /etc/sysctl.conf",
      "sysctl -p",
    ]
  }
}