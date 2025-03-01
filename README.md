# Data Pipeline

Data ingestion project with Apache Airflow

## Requirements

| Package        | Version | Required |
| -------------- | ------- | -------- |
| Python         | 3.12.x  | true     |
| Docker         | latest  | true     |
| Docker compose | latest  | true     |

## Setup your local environment

### Create python3 virtual environment

```bash
python3 -m venv venv
```

### Activate your virtual environment

```bash
source venv/bin/activate
```

### Install python3 modules from requirements.txt

```bash
pip install -r requirements.txt
```

### Run local MWAA environment

This project uses Make commands to automate the setup and local MWAA environment running:

#### Setup the local MWAA environment (only needed once or after cleaning)

MacOS users:

```bash
make setup-mwaa-macos
```

This command will:

- Clone the MWAA local runner repository
- Build the MWAA docker image
- Copy the DAGs to the MWAA environment

#### Start the environment

```bash
make start
```

#### Stop the environment

```bash
make stop
```

#### Clean up everything (remove mwaa-local-runner directory, containers, volumes and images)

```bash
make clean-mwaa
```

## Access the Airflow UI

After starting the environment with `make start` command, you can access:

- Airflow UI: <http://localhost:8080>
- Username: admin
- Password: test
