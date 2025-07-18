resource "docker_image" "grafana" {
  name = var.grafana_image
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.name

  networks_advanced {
    name = docker_network.monitoring.name
  }

  volumes {
    host_path      = abspath("${path.module}/${var.grafana_provisioning_dashboards_path}")
    container_path = "/etc/grafana/provisioning/dashboards"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/${var.grafana_provisioning_datasources_path}")
    container_path = "/etc/grafana/provisioning/datasources"
    read_only      = true
  }
  volumes {
    host_path      = abspath("${path.module}/${var.grafana_dashboards_path}")
    container_path = "/var/lib/grafana/dashboards"
    read_only      = true
  }

  # Standardlabels (falls du sie für Monitoring/Compose nutzt)
  labels {
    label = var.standard_labels["compose_service"]
    value = var.grafana_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }

  # ---- TRAEFIK LABELS ----

  labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "PathPrefix(`/grafana`)"
  }
  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }

 labels {
    label = "traefik.enable"
    value = "true"
  }
  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "PathPrefix(`/grafana`)"
  }
  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }

  # OPTIONAL: kleines Helfer-Redirect nur für /grafana  → /grafana/
  labels {
    label = "traefik.http.middlewares.grafana-slash.redirectregex.regex"
    value = "^/grafana$"
  }
  labels {
    label = "traefik.http.middlewares.grafana-slash.redirectregex.replacement"
    value = "/grafana/"
  }
  labels {
    label = "traefik.http.routers.grafana.middlewares"
    value = "grafana-slash"
  }

  # ---- GRAFANA ENV ----
  env = [
    "GF_SERVER_ROOT_URL=http://localhost/grafana/",
    "GF_SERVER_SERVE_FROM_SUB_PATH=true"
  ]
}
