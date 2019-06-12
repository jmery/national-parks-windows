data "template_file" "install_hab_linux" {
  template = "${file("${path.module}/../templates/install-hab.sh.tpl")}"
  vars {
    ssh_user = "${var.ssh_username}"
  }
}

data "template_file" "permanent_peer" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"
  vars {
    flags = "--auto-update --listen-gossip 0.0.0.0:9638 --listen-http 0.0.0.0:9631 --permanent-peer"
  }
}

data "template_file" "non_permanent_peer" {
  template = "${file("${path.module}/../templates/hab-sup.service")}"
  vars {
    flags = "--auto-update --peer ${google_compute_instance.permanent_peer.network_interface.0.network_ip}"
  }
}

data "template_file" "mongodb_toml" {
  template = "${file("${path.module}/../templates/mongo.toml")}"
}

data "template_file" "haproxy_toml" {
  template = "${file("${path.module}/../templates/haproxy.toml")}"
}

data "template_file" "audit_toml_linux" {
  template = "${file("${path.module}/../templates/audit_linux.toml")}"
  vars {
    automate_url = "${var.automate_url}"
    automate_token = "${var.automate_token}"
    automate_user = "${var.automate_user}"
  }
}

data "template_file" "config_toml_linux" {
  template = "${file("${path.module}/../templates/config_linux.toml")}"
  vars {
    automate_url = "${var.automate_url}"
    automate_token = "${var.automate_token}"
    automate_user = "${var.automate_user}"
  }
}

data "template_file" "windows_bootstrap" {
  template = "${file("${path.module}/../templates/windows_bootstrap.txt.tpl")}"
  vars {
    admin_password = "${var.win_admin_pwd}"
    hab_password = "${var.win_hab_pwd}"
  }
}
