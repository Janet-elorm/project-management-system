import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

@pytest.fixture
def auth_token():
    login_response = client.post(
        "/auth/login",
        json={"email": "janet.ashigbui@icloud.com", "password": "_.ashigbuI_22"}
    )
    assert login_response.status_code == 200
    return login_response.json()["access_token"]

def test_debug_login(auth_token):
    assert auth_token is not None
    print("\n✅ Login Successful! Token:", auth_token[:10], "...", auth_token[-10:])

def test_create_project(auth_token):
    response = client.post(
        "/dashboard/projects/all",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "title": "Test Project from Pytest",
            "description": "Created for test_create_project"
        }
    )
    assert response.status_code in [200, 201]
    project_id = response.json()["project_id"]
    print(f"\n✅ Project created with ID: {project_id}")
    return project_id

def test_create_task(auth_token):
    project_id = test_create_project(auth_token)

    response = client.post(
        f"/dashboard/projects/{project_id}/tasks",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "title": "Pytest Normal Task",
            "category": "To Do",   # ✅ match your ENUM values exactly
            "due_date": "2025-06-01",
            "priority": "High",
            "project_id": project_id,     # <-- ADD THIS
            "assigned_to": 6
        }
    )
    print("\nTask Create Response:", response.json())
    assert response.status_code in [200, 201]

def test_assign_task(auth_token):
    project_id = test_create_project(auth_token)

    response = client.post(
        f"/dashboard/projects/{project_id}/tasks/assign",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "title": "Pytest Assigned Task",
            "category": "To Do",  # ✅ Correct ENUM
            "due_date": "2025-06-02",
            "priority": "Medium",
            "user_ids": [1]  # Make sure user with id=1 exists
        }
    )
    print("\nAssign Task Response:", response.json())
    assert response.status_code in [200, 201]
