terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "monitoring" {
  name = "monitoring"
}

# Loki
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

  labels {
    label = "com.docker.compose.service"
    value = "loki"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
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

  labels {
    label = "logging"
    value = "promtail"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
  }
}

# Prometheus
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

  labels {
    label = "com.docker.compose.service"
    value = "prometheus"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
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

  labels {
    label = "com.docker.compose.service"
    value = "cadvisor"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
  }
}

# Node Exporter
resource "docker_image" "node_exporter" {
  name = "prom/node-exporter:latest"
}

resource "docker_container" "node_exporter" {
  name  = "node_exporter"
  user  = "0:0"
  image = docker_image.node_exporter.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  ports {
    internal = 9100
    external = 9100
  }

  volumes {
    host_path      = "/proc"
    container_path = "/host/proc"
    read_only      = true
  }
  volumes {
    host_path      = "/sys"
    container_path = "/host/sys"
    read_only      = true
  }
  volumes {
    host_path      = "/"
    container_path = "/rootfs"
    read_only      = true
  }

  command = [
    "--path.procfs=/host/proc",
    "--path.sysfs=/host/sys",
    "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($|/)",
    "--path.rootfs=/rootfs"
  ]

  labels {
    label = "com.docker.compose.service"
    value = "node_exporter"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
  }
}

# Alertmanager

resource "docker_image" "alertmanager" {
  name = "prom/alertmanager:latest"
}

resource "docker_container" "alertmanager" {
  name  = "alertmanager"
  image = docker_image.alertmanager.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  ports {
    internal = 9093
    external = 9093
  }

  volumes {
    host_path      = abspath("${path.module}/alertmanager/alertmanager.yml")
    container_path = "/etc/alertmanager/alertmanager.yml"
    read_only      = true
  }

  labels {
    label = "com.docker.compose.service"
    value = "alertmanager"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
  }
}


# Jaeger
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

  labels {
    label = "com.docker.compose.service"
    value = "jaeger"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
  }
}

# Grafana
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

  labels {
    label = "com.docker.compose.service"
    value = "grafana"
  }
  labels {
    label = "com.docker.compose.project"
    value = "monitoring"
  }
}
