# Microservice-Komposition (Docker Compose)

Dieses Verzeichnis enthält das Docker Compose-Setup für die Microservice-Architektur (Product, Order, Payment) sowie die zentrale MariaDB.

## Enthaltene Services

- **product** – Produktverwaltung (Port 8001)
- **order** – Bestellverwaltung (Port 8002)
- **payment** – Zahlungsverwaltung (Port 8003)
- **mariadb** – Zentrale MariaDB mit drei Datenbanken

## Startanleitung

1. **.env anlegen**

   Eine `.env`-Datei mit allen sensiblen Einstellungen (wird automatisch von Compose geladen):

   ```env
   MYSQL_ROOT_PASSWORD=RootGeheimesPasswort
   PRODUCT_DB=productdb
   ORDER_DB=orderdb
   PAYMENT_DB=paymentdb
   MYSQL_USER=bachelor
   MYSQL_PASSWORD=SuperSicher123
   ```

2. **Init-Skript (optional, empfohlen)**

   Im Unterordner `initdb/` sollte ein `init.sql`-Skript liegen, das alle Datenbanken und Rechte anlegt.

3. **Docker Compose Start**

   ```bash
   docker-compose up --build
   ```

## Monitoring-Integration

Das Docker-Netzwerk `monitoring` muss von Terraform bereitgestellt werden.

Die Microservices hängen an diesem Netzwerk (siehe `docker-compose.yml`).

## Zugriffe

| Service  | Adresse auf dem Host| Ardresse im Docker Netzwerk   |
|----------|------------------------------|----------------------|
| Product  | <http://localhost:8001>      |<http://product:8000> |
| Order    | <http://localhost:8002>      |<http://order:8000>   |
| Payment  | <http://localhost:8003>      |<http://payment:8000> |
| MariaDB  | <http://localhost:3306>      |<http://mariadb:3306> |

## Health-Check

Jeder Service bietet `/health` für Monitoring und Orchestrierung an.

## Hinweise

Monitoring/Tracing/Logging (Prometheus, Jaeger, Loki) werden separat per Terraform in `monitoring-infra` gestartet.

Daten und Passwörter nie fest ins Compose schreiben, sondern immer über `.env` und `init.sql`.

## Beenden der Services

```bash
docker-compose down
```

## Verzeichnisstruktur (Beispiel)

```bash
/src
  ├── docker-compose.yml
  ├── .env
  ├── initdb/
  │     └── init.sql
  ├── product/
  ├── order/
  └── payment/
```

---

**Wenn du weitere Dateien als Download möchtest (ZIP etc.), gib gerne Bescheid!**
