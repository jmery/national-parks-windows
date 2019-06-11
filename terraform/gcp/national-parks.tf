data "template_file" "windows_bootstrap" {
  template = "${file("${path.module}/../templates/windows_bootstrap.txt.tpl")}"
  vars {
    admin_password = "${var.win_admin_pwd}"
    hab_password = "${var.win_hab_pwd}"
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
      "powershell -File C:/terraform/install-hab.ps1",
      "C:/ProgramData/chocolatey/bin/hab license accept",
      "C:/ProgramData/chocolatey/bin/hab svc load ${var.national_parks_origin}/tomcat7 --group ${var.hab_group} --channel ${var.hab_prod_channel} --strategy ${var.hab_update_strategy}",
      "powershell New-NetFirewallRule -DisplayName 'National Parks' -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8080",
    ]
  }
}