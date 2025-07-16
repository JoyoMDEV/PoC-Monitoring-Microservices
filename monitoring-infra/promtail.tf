resource "docker_image" "promtail" {
  name = var.promtail_image
}

resource "docker_container" "promtail" {
  name   = "promtail"
  user   = "0:0"
  image  = docker_image.promtail.name

  networks_advanced {
    name = docker_network.monitoring.name
  }
  
  volumes {
    host_path      = abspath("${path.module}/${var.promtail_config_path}")
    container_path = "/etc/promtail/promtail.yaml"
    read_only      = true
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
  volumes {
    host_path      = "/var/lib/docker/containers"
    container_path = "/var/lib/docker/containers"
    read_only      = true
  }
  volumes {
    host_path      = "/etc/hostname"
    container_path = "/etc/hostname"
    read_only      = true
  }

  command = [
    "-config.file=/etc/promtail/promtail.yaml"
  ]

  labels {
    label = var.standard_labels["compose_service"]
    value = var.promtail_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
}
