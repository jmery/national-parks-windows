locals {
  gcp_zone = "${data.google_compute_zones.available.names[0]}"  // Default to first available zone
}

resource "google_compute_instance" "permanent_peer" {
  name         = "permanent-peer-${random_id.random.hex}"
  machine_type = "${var.gcp_machine_type}"
  zone         = "${local.gcp_zone}"
  allow_stopping_for_update = true // Let Terraform resize on the fly if needed

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file("${var.ssh_user_private_key}")}"
  }

  labels {
    x-contact     = "${var.label_contact}"
    x-customer    = "${var.label_customer}"
    x-project     = "${var.label_project}"
    x-dept        = "${var.label_dept}"
    x-application = "${var.label_application}"
    x-ttl         = "${var.label_ttl}"
  }

  metadata {
    sshKeys = "${var.ssh_username}:${file("${var.ssh_user_public_key}")}"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      type = "pd-ssd"
      size = 25
      image = "centos-7"
    }
  }

  network_interface {
    network = "${google_compute_network.network.name}"
    access_config {
    }
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab_linux.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.permanent_peer.rendered}"
    destination = "/home/${var.ssh_username}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.ssh_username}/audit_linux.toml"
  }
   provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.ssh_username}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname permanent-peer",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/config-baseline/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      "sudo cp /home/${var.ssh_username}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      "sudo cp /home/${var.ssh_username}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      //"sudo hab svc load effortless/config-baseline --group ${var.group} --strategy at-once --channel stable",
      //"sudo hab svc load effortless/audit-baseline --group ${var.group} --strategy at-once --channel stable",
    ]

  }
}

resource "google_compute_instance" "mongodb" {
  name         = "mongodb-np-${random_id.random.hex}"
  machine_type = "${var.gcp_machine_type}"
  zone         = "${local.gcp_zone}"
  allow_stopping_for_update = true // Let Terraform resize on the fly if needed

  connection {
    user        = "${var.ssh_username}"
    private_key = "${file("${var.ssh_user_private_key}")}"
  }

  labels {
    x-contact     = "${var.label_contact}"
    x-customer    = "${var.label_customer}"
    x-project     = "${var.label_project}"
    x-dept        = "${var.label_dept}"
    x-application = "${var.label_application}"
    x-ttl         = "${var.label_ttl}"
  }

  metadata {
    sshKeys = "${var.ssh_username}:${file("${var.ssh_user_public_key}")}"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      type = "pd-ssd"
      size = 25
      image = "centos-7"
    }
  }

  network_interface {
    network = "${google_compute_network.network.name}"
    access_config {
    }
  }

  provisioner "file" {
    content     = "${data.template_file.install_hab_linux.rendered}"
    destination = "/tmp/install_hab.sh"
  }

  provisioner "file" {
    content     = "${data.template_file.mongodb.rendered}"
    destination = "/home/${var.ssh_username}/hab-sup.service"
  }

  provisioner "file" {
    content     = "${data.template_file.mongodb_toml.rendered}"
    destination = "/home/${var.ssh_username}/mongo.toml"
  }

  provisioner "file" {
    content     = "${data.template_file.audit_toml_linux.rendered}"
    destination = "/home/${var.ssh_username}/audit_linux.toml"
  }
   provisioner "file" {
    content     = "${data.template_file.config_toml_linux.rendered}"
    destination = "/home/${var.ssh_username}/config_linux.toml"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -rf /etc/machine-id",
      "sudo systemd-machine-id-setup",
      "sudo hostname mongodb-np-${var.hab_prod_channel}",
      "chmod +x /tmp/install_hab.sh",
      "sudo /tmp/install_hab.sh",
      "sleep ${var.sleep}",
      "sudo mkdir -p /hab/user/mongodb/config /hab/user/config-baseline/config /hab/user/audit-baseline/config",
      "sudo chown hab:hab -R /hab/user",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0",
      "sudo /sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0",
      //"sudo cp /home/${var.ssh_username}/audit_linux.toml /hab/user/audit-baseline/config/user.toml",
      //"sudo cp /home/${var.ssh_username}/config_linux.toml /hab/user/config-baseline/config/user.toml",
      "sudo cp /home/${var.ssh_username}/mongo.toml /hab/user/mongodb/config/user.toml",
      //"sudo hab svc load effortless/config-baseline --group ${var.group} --strategy at-once --channel stable",
      //"sudo hab svc load effortless/audit-baseline --group ${var.group} --strategy at-once --channel stable",
      "sudo hab svc load core/mongodb --group ${var.hab_group}"
    ]

  }
}

resource "google_compute_instance" "national_parks" {
  name         = "national-parks-${random_id.random.hex}"
  machine_type = "${var.gcp_machine_type}"
  zone         = "${data.google_compute_zones.available.names[0]}" // Default to first available zone
  allow_stopping_for_update = true // Let Terraform resize on the fly if needed

  connection {
      type     = "winrm"
      user     = "Administrator"
      password = "${var.win_admin_pwd}"
      agent    = "false"
      insecure = "true"
  }

  labels {
    x-contact     = "${var.label_contact}"
    x-customer    = "${var.label_customer}"
    x-project     = "${var.label_project}"
    x-dept        = "${var.label_dept}"
    x-application = "${var.label_application}"
    x-ttl         = "${var.label_ttl}"
  }

  metadata {
    windows-startup-script-ps1 = "${data.template_file.windows_bootstrap.rendered}"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      type = "pd-ssd"
      size = 50
      image = "windows-2016"
    }
  }

  network_interface {
    network = "${google_compute_network.network.name}"
    access_config {
      // Blank access_config creates dynamic external IP address
    }
  }

  provisioner "file" {
    source      = "${path.module}/../templates/install-hab.ps1"
    destination = "C:/terraform/install-hab.ps1"
  }

  provisioner "remote-exec" {
    inline = [
      "powershell -command \"C:/terraform/install-hab.ps1 -PermanentPeer ${google_compute_instance.permanent_peer.network_interface.0.network_ip}\"",
      "C:/ProgramData/chocolatey/bin/hab license accept",
      "C:/ProgramData/chocolatey/bin/hab svc load ${var.national_parks_origin}/tomcat7 --group ${var.hab_group} --channel ${var.hab_prod_channel} --strategy ${var.hab_update_strategy}",
      "powershell New-NetFirewallRule -DisplayName 'National Parks' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080",
    ]
  }
}

