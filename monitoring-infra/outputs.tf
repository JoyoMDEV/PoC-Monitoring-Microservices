output "grafana_url" {
  description = "URL für Grafana Web UI"
  value       = "http://localhost:${var.grafana_port}"
}

output "prometheus_url" {
  description = "URL für Prometheus Web UI"
  value       = "http://localhost:${var.prometheus_port}"
}

output "loki_url" {
  description = "URL für Loki API"
  value       = "http://localhost:${var.loki_port}"
}

output "jaeger_url" {
  description = "URL für Jaeger UI"
  value       = "http://localhost:${var.jaeger_web_port}"
}

output "alertmanager_url" {
  description = "URL für Alertmanager Web UI"
  value       = "http://localhost:${var.alertmanager_port}"
}

output "cadvisor_url" {
  description = "URL für cAdvisor Web UI"
  value       = "http://localhost:${var.cadvisor_port}"
}

output "node_exporter_url" {
  description = "URL für Node Exporter Metrics"
  value       = "http://localhost:${var.node_exporter_port}/metrics"
}

output "promtail_metrics_url" {
  description = "URL für Promtail Metrics"
  value       = "http://localhost:${var.promtail_port}/metrics"
}

output "docker_network_name" {
  description = "Name des verwendeten Docker Netzwerks"
  value       = docker_network.monitoring.name
}
