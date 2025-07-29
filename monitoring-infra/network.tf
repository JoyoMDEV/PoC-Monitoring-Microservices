resource "docker_network" "monitoring" {
  name = var.monitoring_network_name
}

resource "docker_network" "app" {
  name = var.app_network_name
}