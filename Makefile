MONITORING_INFRA=monitoring-infra
SERVICES_DIR=src

.PHONY: all infra services up down logs clean status test

all: up

infra:
	cd $(MONITORING_INFRA) && terraform init && terraform apply -auto-approve

services:
	cd $(SERVICES_DIR) && docker-compose up --build -d

up: infra services

down:
	cd $(SERVICES_DIR) && docker-compose down
	cd $(MONITORING_INFRA) && terraform destroy -auto-approve

logs:
	cd $(SERVICES_DIR) && docker-compose logs -f

status:
	@echo "Docker Compose Services:"
	cd $(SERVICES_DIR) && docker-compose ps
	@echo "Terraform Monitoring-Infra:"
	cd $(MONITORING_INFRA) && terraform show

test:
	cd $(SERVICES_DIR) && pytest tests/ || echo "pytest nicht gefunden oder Fehler"
