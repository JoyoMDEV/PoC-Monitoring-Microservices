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
  image = docker_image.loki.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 3100
    external = 3100
  }
  volumes {
    host_path      = abspath("${path.module}/loki-config.yaml")
    container_path = "/etc/loki/local-config.yaml"
  }
  command = ["-config.file=/etc/loki/local-config.yaml"]
}

# 3. Prometheus
resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}
resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.name
  networks_advanced {
    name = docker_network.monitoring.name
  }
  ports {
    internal = 9090
    external = 9090
  }
  volumes {
    host_path      = abspath("${path.module}/prometheus.yml")
    container_path = "/etc/prometheus/prometheus.yml"
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
}
