resource "docker_image" "cadvisor" {
  name = var.cadvisor_image
}

resource "docker_container" "cadvisor" {
  name  = "cadvisor"
  image = docker_image.cadvisor.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  ports {
    internal = var.cadvisor_port
  }

  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run"
    container_path = "/var/run"
    read_only      = true
  }
  volumes {
    host_path      = "/sys"
    container_path = "/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/var/lib/docker/"
    container_path = "/var/lib/docker"
    read_only      = true
  }
  privileged = true

  labels {
    label = var.standard_labels["compose_service"]
    value = var.cadvisor_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
}
