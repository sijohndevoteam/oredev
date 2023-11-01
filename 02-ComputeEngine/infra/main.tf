provider "google" {
  project = var.project
  region = var.location
}

resource "google_compute_instance" "wordpress" {
  name = "oredev-demo-wordpress"
  machine_type = "n1-standard-2"
  zone = var.zone
  tags = ["wordpress-sm"]
   boot_disk {
    auto_delete = true
    device_name = "instance-1"

    initialize_params {
      image = "projects/debian-cloud/global/images/debian-11-bullseye-v20231010"
      size  = 10
      type  = "pd-balanced"
    }

    mode = "READ_WRITE"
  }

  network_interface {
    network = "default"
    subnetwork = "default"
    access_config {
      // Ephemeral IP
    }
  }
 metadata = {
    ssh-keys = "user:${file("~/.ssh/id_rsa.pub")}"
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y apache2 php libapache2-mod-php php-mysql
    echo '<?php phpinfo(); ?>' > /var/www/html/index.php
    apt-get update
    apt-get install -y mysql-client
    DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
    apt-get install -y php-curl php-gd php-intl php-json php-xml php-zip
    wget https://wordpress.org/latest.tar.gz
    tar xzvf latest.tar.gz
    cp -R wordpress/* /var/www/html/
    chown -R www-data:www-data /var/www/html/
  EOT
}

resource "google_compute_firewall" "wordpress" {
  name = "wordpress"
  network = "default"
  allow {
    protocol = "tcp"
    ports = ["80", "22"]
  }
  source_ranges = ["0.0.0.0/0"]
  direction = "INGRESS"
  priority  = 1000
  target_tags = ["wordpress-sm"]
}


output "instance_external_ip" {
  value = "http://${google_compute_instance.wordpress.network_interface[0].access_config[0].nat_ip}/wp-admin"
  description = "External IP address of the Compute Engine VM with 'http://' prefix"
}
