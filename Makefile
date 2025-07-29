MONITORING_INFRA=monitoring-infra
SERVICES_DIR=python

.PHONY: all infra services up down logs clean status test

all: up

infra:
	cd $(MONITORING_INFRA) && terraform init && terraform apply -auto-approve

python_services:
	cd $(SERVICES_DIR) && docker compose up --build -d

python_up: infra python_services

python_down:
	cd $(SERVICES_DIR) && docker compose down
	cd $(MONITORING_INFRA) && terraform destroy -auto-approve

python_logs:
	cd $(SERVICES_DIR) && docker compose logs -f

python_status:
	@echo "Docker Compose Services:"
	cd $(SERVICES_DIR) && docker compose ps
	@echo "Terraform Monitoring-Infra:"
	cd $(MONITORING_INFRA) && terraform show

python_test:
	cd $(SERVICES_DIR) && pytest tests/ || echo "pytest nicht gefunden oder Fehler"
