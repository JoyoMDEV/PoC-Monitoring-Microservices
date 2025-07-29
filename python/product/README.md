# Product Microservice

Dieser Service verwaltet Produkte in der Microservice-Architektur. Er bietet REST-Endpoints, Monitoring, strukturierte Logs (für Loki) und Tracing (für Jaeger).

## Features

- REST API mit FastAPI (u.a. /products, /products/{id})
- Prometheus-Metrics unter `/metrics`
- Strukturierte Logs (JSON, stdout) für Loki/Grafana
- Jaeger Distributed Tracing
- Health Endpoint: `/health` prüft Service & DB-Verbindung

## API-Endpunkte (Auszug)

- `GET /products/{id}` – Ein Produkt abfragen
- `POST /products` – Neues Produkt anlegen
- `GET /health` – Health-Check

## Start

Service wird über Docker Compose gestartet und liest alle Einstellungen aus Umgebungsvariablen.

## Umgebungsvariablen

| Name        | Beschreibung      | Beispielwert         |
|-------------|-------------------|----------------------|
| DB_HOST     | DB-Hostname       | mariadb              |
| DB_USER     | DB-Benutzer       | bachelor             |
| DB_PASSWORD | DB-Passwort       | SuperSicher123       |
| DB_NAME     | DB-Name           | productdb            |

## Monitoring

- Prometheus: `/metrics`
- Jaeger: Tracing integriert (Service-Name: `product-service`)
- Loki: Logs im JSON-Format auf stdout

## Hinweise

- Health-Endpoint ist Kubernetes/Docker/Prometheus-ready
- Service läuft standardmäßig auf Port 8000 (compose mapped 8001:8000)
