# MWAA Local Runner

MWAA_RUNNER_DIR = aws-mwaa-local-runner
MWAA_RUNNER_REPO = https://github.com/aws/aws-mwaa-local-runner.git
MWAA_VERSION = 2.10.3

MWAA_IMAGE_NAME = amazon/mwaa-local
MWAA_IMAGE_TAG = $(MWAA_VERSION)
MWAA_IMAGE = $(MWAA_IMAGE_NAME):$(MWAA_IMAGE_TAG)

setup-mwaa-macos:
	@echo "=== Starting MWAA Local Runner Setup"

	# Clone MWAA Repository
	@echo "Step 1: Cloning MWAA Local Runner repository..."
	@if [ ! -d "$(MWAA_RUNNER_DIR)" ]; then \
			echo "  -> Cloning from $(MWAA_RUNNER_REPO)..."; \
			git clone $(MWAA_RUNNER_REPO); \
	else \
			echo "  -> Repository already exists. Skipping clone"; \
	fi

	# Modify docker-compose for persistent storage
	@echo "Step 2: Configuring persistent storage for PostgreSQL..."
	@echo "  -> Updating volume configuration in docker-compose-local.yml"
	@sed -i'' -e  's|"$${PWD}/db-data:/var/lib/postgresql/data"|postgres_data:/var/lib/postgresql/data|g' $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml
	@if ! grep -q "ˆvolumes:" $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml; then \
			echo "  -> Adding volumes section to docker-compose-local.yml"; \
			echo "\nvolumes:\n  postgres_data:" >> $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml; \
	fi

	# Modify docker-compose to link dags folder
	@echo "Step 3: Link dags folder"
	@sed -i'' -e  's|"$${PWD}/dags:/usr/local/airflow/dags"|${PWD}/dags:/usr/local/airflow/dags|g' $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml
	@sed -i'' -e  's|"$${PWD}/plugins:/usr/local/airflow/plugins"|${PWD}/$(MWAA_RUNNER_DIR)/plugins:/usr/local/airflow/plugins|g' $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml
	@sed -i'' -e  's|"$${PWD}/requirements:/usr/local/airflow/requirements"|${PWD}/$(MWAA_RUNNER_DIR)/requirements:/usr/local/airflow/requirements|g' $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml
	@sed -i'' -e  's|"$${PWD}/startup_script:/usr/local/airflow/startup"|${PWD}:/usr/local/airflow/startup|g' $(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml

	# Add Python dependencies to requirements/requirements.txt
	@echo "Step 4: Copying requirements.txt to MWAA folder..."
	@cp requirements.txt $(MWAA_RUNNER_DIR)/requirements/requirements.txt

	# Build MWAA Docker image
	@echo "Step 5: Building MWAA Docker container image ($(MWAA_IMAGE))..."
	@cd $(MWAA_RUNNER_DIR) && \
	./mwaa-local-env build-image

	@echo "=== MWAA Local Runner Setup Complete ==="
	@echo "MWAA Version: $(MWAA_VERSION)"
	@echo "Docker Image: $(MWAA_IMAGE)"
	@echo "You can now start the environment with: make start"

# Start local development
start:
	docker compose -p local-airflow -f ./$(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml up -d
	@echo "Local Airflow has started"
	@echo "To stop the local environment, Ctrl+C on the terminal or run: make stop"

# Stop local development
stop:
	docker compose -p local-airflow -f ./$(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml stop
	@echo "Local Airflow has stopped"

# Clean Docker artifacts and mwaa-local-runner directory
clean-mwaa:
	@echo "Removing MWAA Docker containers and networks..."
	docker compose -p local-airflow -f ./$(MWAA_RUNNER_DIR)/docker/docker-compose-local.yml down || true

	@echo "Removing MWAA Docker volumes..."
	docker volume rm local-airflow_postgres_data || true
	
	# Remove MWAA runner directory
	@echo "Removing mwaa-local-runner directory..."
	@rm -rf $(MWAA_RUNNER_DIR)

	@echo "=== MWAA Environment Cleanup Complete ==="
