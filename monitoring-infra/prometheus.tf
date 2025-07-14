resource "docker_image" "prometheus" {
  name = var.prometheus_image
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  user  = "0:0"
  image = docker_image.prometheus.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  ports {
    internal = var.prometheus_port
    external = var.prometheus_port
  }

  volumes {
    host_path      = abspath("${path.module}/${var.prometheus_config_path}")
    container_path = "/etc/prometheus/prometheus.yml"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }

  labels {
    label = var.standard_labels["compose_service"]
    value = var.prometheus_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
}
