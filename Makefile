MONITORING_INFRA=monitoring-infra
SERVICES_DIR_PYTHON=python
SERVICES_DIR_JAVA=java-spring-boot

.PHONY: all infra services up down logs clean status test

all: up

infra:
	cd $(MONITORING_INFRA) && terraform init && terraform apply -auto-approve

python_services:
	cd $(SERVICES_DIR_PYTHON) && docker compose up --build -d

python_up: infra python_services

python_down:
	cd $(SERVICES_DIR_PYTHON) && docker compose down
	cd $(MONITORING_INFRA) && terraform destroy -auto-approve

python_logs:
	cd $(SERVICES_DIR_PYTHON) && docker compose logs -f

python_status:
	@echo "Docker Compose Services:"
	cd $(SERVICES_DIR_PYTHON) && docker compose ps
	@echo "Terraform Monitoring-Infra:"
	cd $(MONITORING_INFRA) && terraform show

python_test:
	cd $(SERVICES_DIR_PYTHON) && pytest tests/ || echo "pytest nicht gefunden oder Fehler"

java_services:
	cd $(SERVICES_DIR_JAVA) && docker compose up --build -d

java_up: infra java_services

java_down:
	cd $(SERVICES_DIR_JAVA) && docker compose down
	cd $(MONITORING_INFRA) && terraform destroy -auto-approve

java_logs:
	cd $(SERVICES_DIR_JAVA) && docker compose logs -f

java_status:
	@echo "Docker Compose Services:"
	cd $(SERVICES_DIR_JAVA) %% docker compose ps -a
	@echo "Terraform Monitoring-Infra:"
	cd $(MONITORING_INFRA) && terraform show
