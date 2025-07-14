terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# 1. Gemeinsames Netzwerk für Monitoring und Microservices
resource "docker_network" "monitoring" {
  name = "monitoring"
}

# 2. Loki
resource "docker_image" "loki" {
  name = "grafana/loki:latest"
}
resource "docker_container" "loki" {
  name  = "loki"
  user  = "0:0"
  image = docker_image.loki.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 3100
    external = 3100
  }
  volumes {
    host_path      = abspath("${path.module}/loki/loki-config.yaml")
    container_path = "/etc/loki/local-config.yaml"
  }
  command = [
    "-config.file=/etc/loki/local-config.yaml",
    "-validation.allow-structured-metadata=false"
  ]
  labels = {
    "com.docker.compose.service" = "loki"
    "com.docker.compose.project" = "monitoring"
  }
}

# Promtail
resource "docker_image" "promtail" {
  name = "grafana/promtail:latest"
}
resource "docker_container" "promtail" {
  name   = "promtail"
  user   = "0:0"
  image  = docker_image.promtail.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 9080
    external = 9080
  }
  volumes {
    host_path      = abspath("${path.module}/promtail/promtail-config.yaml")
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
  command = ["-config.file=/etc/promtail/promtail.yaml"]
    labels = {
    "com.docker.compose.service" = "promtail"
    "com.docker.compose.project" = "monitoring"
  }
}

# 3. Prometheus
resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}
resource "docker_container" "prometheus" {
  name  = "prometheus"
  user  = "0:0"
  image = docker_image.prometheus.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = abspath("${path.module}/prometheus/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
  }
  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
    read_only      = true
  }
    labels = {
    "com.docker.compose.service" = "prometheus"
    "com.docker.compose.project" = "monitoring"
  }
}

# cAdvisor
resource "docker_image" "cadvisor" {
  name = "gcr.io/cadvisor/cadvisor:latest"
}

resource "docker_container" "cadvisor" {
  name  = "cadvisor"
  image = docker_image.cadvisor.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 8080
    external = 8080
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
    labels = {
    "com.docker.compose.service" = "cadvisor"
    "com.docker.compose.project" = "monitoring"
  }
}


# 4. Jaeger
resource "docker_image" "jaeger" {
  name = "jaegertracing/all-in-one:latest"
}
resource "docker_container" "jaeger" {
  name  = "jaeger"
  image = docker_image.jaeger.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 6831
    external = 6831
    protocol = "udp"
  }
  ports {
    internal = 16686
    external = 16686
  }
    labels = {
    "com.docker.compose.service" = "jaeger"
    "com.docker.compose.project" = "monitoring"
  }
}

# 5. (Optional) Grafana für Visualisierung
resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}
resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 3000
    external = 3000
  }
  volumes {
    host_path      = abspath("${path.module}/grafana/provisioning/dashboards")
    container_path = "/etc/grafana/provisioning/dashboards"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/grafana/provisioning/datasources")
    container_path = "/etc/grafana/provisioning/datasources"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/grafana/dashboards")
    container_path = "/var/lib/grafana/dashboards"
    read_only      = true
  }
    labels = {
    "com.docker.compose.service" = "grafana"
    "com.docker.compose.project" = "monitoring"
  }
}
