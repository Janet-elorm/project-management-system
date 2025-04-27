import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

# Fixtures
@pytest.fixture
def auth_token():
    """Get authentication token for tests"""
    response = client.post(
        "/auth/login",
        json={"email": "janet.ashigbui@icloud.com", "password": "_.ashigbuI_22"}
    )
    return response.json()["access_token"]

@pytest.fixture
def test_project(auth_token):
    """Create a test project"""
    response = client.post(
        "/dashboard/projects/all",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={"title": "Test Project", "description": "For testing"}
    )
    return response.json()

# Authentication Tests
def test_invalid_login():
    response = client.post(
        "/auth/login",
        json={"email": "nonexistent@test.com", "password": "wrong"}
    )
    assert response.status_code == 401

# Project Tests
def test_create_project(auth_token):
    response = client.post(
        "/dashboard/projects/all",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={"title": "New Project", "description": "Testing"}
    )
    assert response.status_code in [200, 201]
    assert "project_id" in response.json()

# Task Tests
def test_full_task_workflow(auth_token, test_project):
    project_id = test_project["project_id"]

    # Create task
   # Create task
task_res = client.post(
    f"/dashboard/projects/{project_id}/tasks/assign",
    headers={"Authorization": f"Bearer {auth_token}"},
    json={
        "title": "Test Task",
        "category": "To Do",
        "due_date": "2025-12-31",
        "priority": "High",
        "user_ids": [1]
    }
)
assert task_res.status_code in [200, 201]
task_id = task_res.json()["task_id"]


    # Assign task (already assigned during creation if using task create+assign combined)
    assign_res = client.post(
        f"/dashboard/projects/{project_id}/tasks/assign",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "title": "Assigned Task",
            "category": "To Do",
            "due_date": "2025-12-31",
            "priority": "Medium",
            "user_ids": [1]
        }
    )
    assert assign_res.status_code in [200, 201]

    # Verify task listing
    get_res = client.get(
        f"/dashboard/projects/{project_id}/tasks",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert any(t["task_id"] == task_id for t in get_res.json())

# Edge Case Test
def test_empty_task_title(auth_token, test_project):
    project_id = test_project["project_id"]

    response = client.post(
        f"/dashboard/projects/{project_id}/tasks",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "title": "",
            "category": "To Do",
            "due_date": "2025-12-31",
            "priority": "High",
            "user_ids": [1]
        }
    )
    assert response.status_code == 422  # Should fail validation
