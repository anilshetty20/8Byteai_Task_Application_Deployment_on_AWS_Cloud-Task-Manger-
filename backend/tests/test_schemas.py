import pytest
from pydantic import ValidationError
from app.schemas import TaskCreate

def test_valid_task():
    task = TaskCreate(title="Write Terraform", status="todo")
    assert task.title == "Write Terraform"
    assert task.status == "todo"

def test_empty_title_is_rejected():
    with pytest.raises(ValidationError):
        TaskCreate(title="   ")
