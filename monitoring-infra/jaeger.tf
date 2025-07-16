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
    protocol = "udp"
  }
  ports {
    internal = var.jaeger_web_port
  }

  ports {
    internal = var.jaeger_otlp_port
  }

  labels {
    label = var.standard_labels["compose_service"]
    value = var.jaeger_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
  labels {
  label = "traefik.enable"
  value = "true"
  }
  labels {
    label = "traefik.tcp.routers.jaeger-otlp.entrypoints"
    value = "otlp"
  }
  labels {
    label = "traefik.tcp.routers.jaeger-otlp.rule"
    value = "HostSNI(`*`)"
  }
  labels {
    label = "traefik.tcp.services.jaeger-otlp.loadbalancer.server.port"
    value = "4317"
  }

}
