# Monitoring- und Observability-Stack mit Terraform

Dieses Repository enthält eine produktionsnahe Monitoring- und Observability-Lösung für Microservices, komplett als Infrastruktur-Code mit **Terraform** realisiert.

## Features

- **Prometheus** (Metriken) inkl. Alerting/Alertmanager
- **Grafana** (Dashboards, zentrale UI, Alerts)
- **Loki** & **Promtail** (Log Aggregation)
- **Jaeger** (Distributed Tracing)
- **Node Exporter & cAdvisor** (System- und Container-Metriken)
- **Dashboards as Code** und zentrale Konfigurationsdateien
- **Alles als Code** – vollständig versionierbar & dokumentierbar

## Projektstruktur

```plaintext
│   alertmanager.tf
│   cadvisor.tf
│   grafana.tf
│   jaeger.tf
│   loki.tf
│   main.tf
│   network.tf
│   node_exporter.tf
│   outputs.tf
│   prometheus.tf
│   promtail.tf
│   README.md
│   variables.tf
│
├───alertmanager
│       alertmanager.yml
│
├───grafana
│   ├───dashboards
│   │       docker-overview.json
│   │       loki-logs.json
│   │       Observability-Overview.json
│   │       tracing-overview.json
│   │
│   └───provisioning
│       ├───dashboards
│       │       my-dashboards.yml
│       │
│       └───datasources
│               datasources.yaml
│
├───loki
│       loki-config.yaml
│
├───prometheus
│       alert.rules.yml
│       prometheus.yml
│
└───promtail
        promtail-config.yaml
```

## Quickstart

1. **Voraussetzungen:**
   - [Terraform](https://www.terraform.io/downloads)
   - [Docker & Docker Compose](https://docs.docker.com/get-docker/)
   - (Optional für Alertmanager-Mail: SMTP-Daten)

2. **Stack ausrollen**

   ```bash
   terraform init
   terraform apply
   ```

3. **Zugriffe nach dem Deploy (Standard-Ports):**

   - **Grafana:**         <http://localhost:3000>
   - **Prometheus:**      <http://localhost:9090>
   - **Loki API:**        <http://localhost:3100>
   - **Promtail Metrics:** <http://localhost:9080/metrics>
   - **Jaeger UI:**       <http://localhost:16686>
   - **Alertmanager:**    <http://localhost:9093>
   - **cAdvisor:**        <http://localhost:8080>
   - **Node Exporter:**   <http://localhost:9100/metrics>

4. **Grafana Login:**
   - Standard-Login: `admin` / `admin` (beim ersten Login Passwort ändern)
   - Dashboards werden automatisch provisioniert!

5. **Konfigurationsanpassungen:**
   - Ports, Container-Namen, Pfade, Labels etc. zentral in `variables.tf` ändern
   - Service-Konfigurationen (z.B. Prometheus, Loki, Grafana) in den jeweiligen Unterordnern (`prometheus/`, `loki/`, ...)

6. **Dashboards & Alerting:**
   - Dashboards als JSON unter `grafana/dashboards/`
   - Alerting-Regeln in `prometheus/alert.rules.yml`
   - Alertmanager-Konfiguration unter `alertmanager/alertmanager.yml`

## Hinweise zur Bachelorarbeit

- Der Stack bildet eine **moderne Observability-Lösung** für Microservices-Architekturen ab.
- Jede Komponente ist **als Code definiert** (IaC, Dashboards-as-Code, Alerting-as-Code).
- Die Struktur ist **modular und skalierbar**: Erweiterungen (z.B. weitere Exporter, andere Backends) sind einfach möglich.
- Der Stack eignet sich ideal, um Best Practices in Sachen Monitoring, Logging und Tracing zu demonstrieren.

## Weiterführende Ideen

- Integration weiterer Exporter (Blackbox, mysqld, redis, etc.)
- Anbindung an andere Notification-Kanäle (Slack, Teams, Webhook) im Alertmanager
- Betrieb in Produktivumgebungen, Deployment in die Cloud (z.B. mit Terraform-Modulen für AWS/GCP)

## Kontakt

Fragen, Feedback oder Anregungen?  
Erstellt gerne ein Issue oder meldet euch direkt!

---
