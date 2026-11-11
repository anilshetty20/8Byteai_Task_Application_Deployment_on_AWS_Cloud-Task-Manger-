import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy import select, func
from .database import Base, engine, get_db
from .models import Task
from .schemas import TaskCreate, TaskUpdate, TaskRead

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("task-manager")

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Convenient for the local starter. For production, use Alembic migrations.
    Base.metadata.create_all(bind=engine)
    logger.info("Task Manager API started")
    yield
    logger.info("Task Manager API stopped")

app = FastAPI(title="Task Manager API", version="1.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/api/tasks", response_model=list[TaskRead])
def list_tasks(status: str | None = Query(default=None), db: Session = Depends(get_db)):
    query = select(Task).order_by(Task.id.desc())
    if status:
        if status not in {"todo", "in_progress", "done"}:
            raise HTTPException(status_code=400, detail="Invalid status")
        query = query.where(Task.status == status)
    return db.scalars(query).all()

@app.post("/api/tasks", response_model=TaskRead, status_code=201)
def create_task(payload: TaskCreate, db: Session = Depends(get_db)):
    task = Task(**payload.model_dump())
    db.add(task)
    db.commit()
    db.refresh(task)
    logger.info("Created task id=%s", task.id)
    return task

@app.patch("/api/tasks/{task_id}", response_model=TaskRead)
def update_task(task_id: int, payload: TaskUpdate, db: Session = Depends(get_db)):
    task = db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(task, key, value)
    db.commit()
    db.refresh(task)
    logger.info("Updated task id=%s", task.id)
    return task

@app.delete("/api/tasks/{task_id}", status_code=204)
def delete_task(task_id: int, db: Session = Depends(get_db)):
    task = db.get(Task, task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    db.delete(task)
    db.commit()
    logger.info("Deleted task id=%s", task_id)

@app.get("/api/stats")
def task_stats(db: Session = Depends(get_db)):
    rows = db.execute(
        select(Task.status, func.count(Task.id)).group_by(Task.status)
    ).all()
    counts = {"todo": 0, "in_progress": 0, "done": 0}
    counts.update({status: count for status, count in rows})
    return {"total": sum(counts.values()), **counts}
