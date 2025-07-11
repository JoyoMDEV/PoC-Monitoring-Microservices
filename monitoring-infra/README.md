# Monitoring-Infrastruktur mit Terraform und Docker

Dieses Projekt stellt eine wiederverwendbare Infrastruktur für das Monitoring und Observability einer Microservice-Architektur bereit.  
Deployt werden mit Terraform die Services **Prometheus**, **Jaeger**, **Loki** sowie optional **Grafana** – alle als Docker-Container im gleichen Docker-Netzwerk.

## Übersicht

- **Prometheus**: Monitoring & Metrics für Microservices (z. B. FastAPI-Services)
- **Loki**: Zentrale Sammlung und Verwaltung von Logs
- **Jaeger**: Distributed Tracing für Microservices (OpenTelemetry-kompatibel)
- **Grafana** (optional): Visualisierung von Logs und Metriken
- **Terraform**: Infrastructure as Code (IaC) zur einfachen, reproduzierbaren Bereitstellung

---

## Projektstruktur

```
/monitoring-infra/
  ├── main.tf               # Haupt-Terraform-Konfiguration
  ├── outputs.tf            # (optional) Ausgaben, z. B. Service-URLs
  ├── prometheus.yml        # Prometheus-Targets (Microservices als Monitoring-Ziel)
  ├── loki-config.yaml      # Loki-Konfiguration
  └── README.md             # Diese Dokumentation
```

---

## Voraussetzungen

- **Docker** (mind. Version 20.x)
- **Terraform** (mind. Version 1.x)
- Empfohlen: `docker-compose` für Microservices (z. B. Product-Service) im selben Netzwerk

---

## Nutzung

### 1. Projekt initialisieren

```bash
cd monitoring-infra
terraform init
```

### 2. Infrastruktur aufbauen

```bash
terraform apply
```
Bestätige mit `yes`, wenn du dazu aufgefordert wirst.

---

## Hinweise zur Integration mit Microservices

- Deine Microservices (z. B. `product`) sollten im gleichen Docker-Netzwerk laufen wie die Monitoring-Services.
- Im Docker-Compose-File der Microservices:
  ```yaml
  networks:
    monitoring:
      external: true
  ```
  und für jeden Service:
  ```yaml
  networks:
    - monitoring
  ```
- In der `prometheus.yml` können die Ziel-Services (z. B. `product:8000`) direkt angegeben werden.

---

## Zugriffe auf die Dienste

| Dienst      | URL                        | Beschreibung                    |
|-------------|----------------------------|----------------------------------|
| Prometheus  | http://localhost:9090      | Monitoring-Oberfläche           |
| Loki        | http://localhost:3100      | API für Log-Sammlung            |
| Jaeger      | http://localhost:16686     | Tracing-Oberfläche              |
| Grafana     | http://localhost:3000      | (optional) Visualisierung       |

---

## Abschalten

Alle mit Terraform gestarteten Container können mit
```bash
terraform destroy
```
beendet und gelöscht werden.

---

## Weiterführendes

- [Prometheus Doku](https://prometheus.io/docs/introduction/overview/)
- [Grafana Doku](https://grafana.com/docs/grafana/latest/)
- [Jaeger Doku](https://www.jaegertracing.io/docs/)
- [Loki Doku](https://grafana.com/docs/loki/latest/)
- [Terraform Docker Provider](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs)

---

**Tipp für die Bachelorarbeit:**  
Dieses Setup erlaubt eine 100% reproduzierbare, versionierte Monitoring-Infrastruktur – ideal für Doku, Teamwork und Weiterentwicklung.
