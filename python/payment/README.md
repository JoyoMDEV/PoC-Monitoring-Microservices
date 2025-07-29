# Payment Microservice

Dieser Service verwaltet Zahlungen. Enthält REST-API, Monitoring, strukturierte Logs (Loki) und Tracing (Jaeger).

## Features

- REST API mit FastAPI (u.a. /payments, /payments/{id})
- Prometheus-Metrics unter `/metrics`
- Strukturierte Logs (JSON, stdout) für Loki/Grafana
- Jaeger Distributed Tracing
- Health Endpoint: `/health` prüft Service & DB-Verbindung

## API-Endpunkte (Auszug)

- `GET /payments/{id}` – Zahlung abfragen
- `POST /payments` – Neue Zahlung anlegen
- `GET /health` – Health-Check

## Start

Service wird via Docker Compose gestartet, Konfiguration per Umgebungsvariablen.

## Umgebungsvariablen

| Name        | Beschreibung      | Beispielwert         |
|-------------|-------------------|----------------------|
| DB_HOST     | DB-Hostname       | mariadb              |
| DB_USER     | DB-Benutzer       | bachelor             |
| DB_PASSWORD | DB-Passwort       | SuperSicher123       |
| DB_NAME     | DB-Name           | paymentdb            |

## Monitoring

- Prometheus: `/metrics`
- Jaeger: Tracing integriert (Service-Name: `payment-service`)
- Loki: Logs im JSON-Format auf stdout

## Hinweise

- Health-Endpoint ist Kubernetes/Docker/Prometheus-ready
- Service läuft standardmäßig auf Port 8000 (compose mapped 8003:8000)
