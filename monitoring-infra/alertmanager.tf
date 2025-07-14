resource "docker_image" "alertmanager" {
  name = var.alertmanager_image
}

resource "docker_container" "alertmanager" {
  name  = "alertmanager"
  image = docker_image.alertmanager.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  ports {
    internal = var.alertmanager_port
    external = var.alertmanager_port
  }

  volumes {
    host_path      = abspath("${path.module}/${var.alertmanager_config_path}")
    container_path = "/etc/alertmanager/alertmanager.yml"
    read_only      = true
  }

  labels {
    label = var.standard_labels["compose_service"]
    value = var.alertmanager_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
}
