resource "docker_image" "jaeger" {
  name = var.jaeger_image
}

resource "docker_container" "jaeger" {
  name  = "jaeger"
  image = docker_image.jaeger.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  ports {
    internal = var.jaeger_udp_port
    external = var.jaeger_udp_port
    protocol = "udp"
  }
  ports {
    internal = var.jaeger_web_port
    external = var.jaeger_web_port
  }

  labels {
    label = var.standard_labels["compose_service"]
    value = var.jaeger_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
}
