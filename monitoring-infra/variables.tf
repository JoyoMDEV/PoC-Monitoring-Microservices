variable "monitoring_network_name" {
  description = "Name des Docker Netzwerks für Monitoring"
  type        = string
  default     = "monitoring"
}

variable "app_network_name" {
  description = "Name des Docker Netzwerks für die Anwendung"
  type        = string
  default     = "app"
}

variable "traefik_image" {
  description = "Traefik Docker Image"
  type        = string
  default     = "traefik:v3.0"
}

variable "loki_image" {
  description = "Loki Docker Image"
  type        = string
  default     = "grafana/loki:latest"
}

variable "promtail_image" {
  description = "Promtail Docker Image"
  type        = string
  default     = "grafana/promtail:latest"
}

variable "prometheus_image" {
  description = "Prometheus Docker Image"
  type        = string
  default     = "prom/prometheus:latest"
}

variable "grafana_image" {
  description = "Grafana Docker Image"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "jaeger_image" {
  description = "Jaeger Docker Image"
  type        = string
  default     = "jaegertracing/all-in-one:latest"
}

variable "node_exporter_image" {
  description = "Node Exporter Docker Image"
  type        = string
  default     = "prom/node-exporter:latest"
}

variable "cadvisor_image" {
  description = "cAdvisor Docker Image"
  type        = string
  default     = "gcr.io/cadvisor/cadvisor:latest"
}

variable "alertmanager_image" {
  description = "Alertmanager Docker Image"
  type        = string
  default     = "prom/alertmanager:latest"
}

# Beispiel für Ports – nach Belieben anpassen/ergänzen
variable "loki_port"     { default = 3100 }
variable "promtail_port" { default = 9080 }
variable "prometheus_port" { default = 9090 }
variable "grafana_port"  { default = 3000 }
variable "jaeger_web_port" { default = 16686 }
variable "jaeger_udp_port" { default = 6831 }
variable "jaeger_otlp_port" { default = 4317 }
variable "node_exporter_port" { default = 9100 }
variable "cadvisor_port" { default = 8080 }
variable "alertmanager_port" { default = 9093 }
variable "traefik_port" { default = 80 }
variable "traefik_web_port" { default = 8080 }

# Pfade für Konfigurationsdateien – nach deinem Projekt anpassen!
variable "loki_config_path" {
  default = "loki/loki-config.yaml"
}
variable "promtail_config_path" {
  default = "promtail/promtail-config.yaml"
}
variable "prometheus_config_path" {
  default = "prometheus/prometheus.yml"
}
variable "alertmanager_config_path" {
  default = "alertmanager/alertmanager.yml"
}
variable "grafana_dashboards_path" {
  default = "grafana/dashboards"
}
variable "grafana_provisioning_dashboards_path" {
  default = "grafana/provisioning/dashboards"
}
variable "grafana_provisioning_datasources_path" {
  default = "grafana/provisioning/datasources"
}

variable "standard_labels" {
  description = "Map für häufig verwendete Docker Labels"
  type = map(string)
  default = {
    compose_service  = "com.docker.compose.service"
    compose_project  = "com.docker.compose.project"
    logging         = "logging"
    # beliebig erweiterbar, z.B. monitoring = "monitoring"
  }
}

variable "loki_service_label" {
  default = "loki"
}

variable "promtail_service_label" {
  default = "promtail"
}

variable "prometheus_service_label" {
  default = "prometheus"
}

variable "grafana_service_label" {
  default = "grafana"
}

variable "traefik_service_labe" {
  default = "traefik"
}

variable "jaeger_service_label" {
  default = "jaeger"
}

variable "node_exporter_service_label" {
  default = "node_exporter"
}

variable "cadvisor_service_label" {
  default = "cadvisor"
}

variable "alertmanager_service_label" {
  default = "alertmanager"
}

variable "compose_project_label" {
  default = "monitoring"
}

