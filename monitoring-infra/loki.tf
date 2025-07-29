resource "docker_image" "loki" {
  name = var.loki_image
}

resource "docker_container" "loki" {
  name  = "loki"
  user  = "0:0"
  image = docker_image.loki.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  volumes {
    host_path      = abspath("${path.module}/${var.loki_config_path}")
    container_path = "/etc/loki/local-config.yaml"
  }

  command = [
    "-config.file=/etc/loki/local-config.yaml",
    "-validation.allow-structured-metadata=false"
  ]

    labels {
    label = var.standard_labels["compose_service"]
    value = var.loki_service_label
    }
    labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
    }

}
