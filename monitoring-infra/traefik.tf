resource "docker_image" "traefik" {
    name = var.traefik_image
}

resource "docker_container" "traefik" {
    name    = "traefik"
    image   = docker_image.traefik.name
    user    = "0:0"

    networks_advanced {
        name = var.monitoring_network_name
    }

    networks_advanced {
        name = var.app_network_name
    }


    ports {
        internal = var.nginx_port
    }

    ports {
        internal = var.traefik_web_port
        external = var.traefik_web_port
    }

    volumes {
        host_path      = "var/run/docker.sock"
        container_path = "/var/run/docker.sock"
        read_only      = false
    }

    command = [
        "--providers.docker=true",
        "--providers.docker.exposedbydefault=false",
        "--entrypoints.otlp.address=:4317",  
        "--entrypoints.web.address=:80",
        "--api.dashboard=true",
        "--api.insecure=true"
    ]
}