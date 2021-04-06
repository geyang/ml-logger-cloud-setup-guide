provider "google" {
  credentials = file("~/.gce/improbable-ai.json")
  project = "improbable-ai-4682"
  region = "us-west1"
}

resource "google_compute_firewall" "ssh-rule" {
  name = "demo-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports = [ "22"]
  }
  target_tags = [ "ml-logger"]
  source_ranges = ["0.0.0.0/0"]
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
  byte_length = 8
}

// A single Compute Engine instance
resource "google_compute_instance" "default" {
  name = "ml-logger-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone = "us-west1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  // Make sure flask is installed on all new instances for later steps
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }
  metadata = {
    ssh-keys = "ge_ike_yang:${file("~/.ssh/ge-improbable-gce.pub")}"
  }
  depends_on = [google_compute_firewall.ssh-rule]
  connection {
    type = "ssh"
    user = "ge_ike_yang"
    host = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
    private_key = "${file("~/.ssh/ge-improbable-gce")}"
  }

  provisioner "file" {
    source      = "./start.sh"
    destination = "/home/ge_ike_yang/start.sh"
  }
}

output "ip" {
  value = google_compute_instance.default.network_interface.0.access_config.0.nat_ip
}
