# Order Microservice

Dieser Service verwaltet Bestellungen. REST, Monitoring, strukturierte Logs (Loki) und Tracing (Jaeger) sind vollständig integriert.

## Features

- REST API mit FastAPI (u.a. /orders, /orders/{id})
- Prometheus-Metrics unter `/metrics`
- Strukturierte Logs (JSON, stdout) für Loki/Grafana
- Jaeger Distributed Tracing
- Health Endpoint: `/health` prüft Service & DB-Verbindung

## API-Endpunkte (Auszug)

- `GET /orders/{id}` – Bestellung abfragen
- `POST /orders` – Neue Bestellung anlegen
- `GET /health` – Health-Check

## Start

Start erfolgt über Docker Compose, Einstellungen über Umgebungsvariablen.

## Umgebungsvariablen

| Name        | Beschreibung      | Beispielwert         |
|-------------|-------------------|----------------------|
| DB_HOST     | DB-Hostname       | mariadb              |
| DB_USER     | DB-Benutzer       | bachelor             |
| DB_PASSWORD | DB-Passwort       | SuperSicher123       |
| DB_NAME     | DB-Name           | orderdb              |

## Monitoring

- Prometheus: `/metrics`
- Jaeger: Tracing integriert (Service-Name: `order-service`)
- Loki: Logs im JSON-Format auf stdout

## Hinweise

- Health-Endpoint ist Kubernetes/Docker/Prometheus-ready
- Service läuft standardmäßig auf Port 8000 (compose mapped 8002:8000)
