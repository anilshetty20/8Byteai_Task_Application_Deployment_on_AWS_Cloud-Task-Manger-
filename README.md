# AWS DevOps Assignment — Task Manager

A three-tier task management sample application built to demonstrate Terraform-based AWS infrastructure, Docker, CI/CD, monitoring, logging, and documentation.

## Stack
- Frontend: React + Vite
- API: Python + FastAPI
- Database: PostgreSQL 16
- Local orchestration: Docker Compose

## Run locally
Prerequisites: Docker Engine and Docker Compose.

```bash
docker compose up --build
```

Open:
- Frontend: http://localhost:5173
- API health: http://localhost:8000/health
- Swagger API docs: http://localhost:8000/docs

Stop containers:

```bash
docker compose down
```

Remove local database data (destructive):

```bash
docker compose down -v
```

## API endpoints
| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/health` | Health check |
| GET | `/api/tasks` | List tasks |
| GET | `/api/tasks?status=todo` | Filter tasks |
| POST | `/api/tasks` | Create task |
| PATCH | `/api/tasks/{id}` | Update task |
| DELETE | `/api/tasks/{id}` | Delete task |
| GET | `/api/stats` | Task counts by status |

## Tests
The starter includes schema validation tests. Run them locally:

```bash
cd backend
python -m venv .venv
# Activate the virtual environment, then:
pip install -r requirements.txt
pytest
```

## Next assignment phases
1. Provision AWS networking, EC2, ALB, and private PostgreSQL RDS using Terraform.
2. Build GitHub Actions workflows for tests, image publishing, staging, and production.
3. Configure CloudWatch, Prometheus, Grafana, and centralized logs.
4. Expand this README with architecture, deployment, and security documentation.

## Security notes
The credentials in `docker-compose.yml` are disposable local-development credentials only. Do not reuse them in AWS. Production secrets must be stored in AWS Secrets Manager or another approved secret store. Keep RDS private and restrict database access to the application security group.
