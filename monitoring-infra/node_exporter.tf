resource "docker_image" "node_exporter" {
  name = var.node_exporter_image
}

resource "docker_container" "node_exporter" {
  name  = "node_exporter"
  user  = "0:0"
  image = docker_image.node_exporter.name

  networks_advanced {
    name = docker_network.monitoring.name
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
    "--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc|run/user)($|/)",
    "--path.rootfs=/rootfs"
  ]

  labels {
    label = var.standard_labels["compose_service"]
    value = var.node_exporter_service_label
  }
  labels {
    label = var.standard_labels["compose_project"]
    value = var.compose_project_label
  }
}
