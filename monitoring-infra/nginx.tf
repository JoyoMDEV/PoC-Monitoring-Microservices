resource "docker_image" "nginx" {
    name = var.nginx_image
}

resource "docker_container" "nginx" {
    name    = "nginx"
    image   = docker_image.nginx.name
    user    = "0:0"

    networks_advanced {
        name = var.monitoring_network_name
    }

    networks_advanced {
        name = var.app_network_name
    }

    volumes {
        host_path      = abspath("${path.module}/nginx/nginx.conf")
        container_path = "/etc/nginx/nginx.conf"
        read_only      = true
    }

    ports {
        internal = var.nginx_port
    }
}