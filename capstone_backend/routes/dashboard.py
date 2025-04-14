from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, HTTPException
from sqlalchemy.orm import Session
from db import get_db
import models, schemas, crud
from typing import List, Dict
from routes.auth import decode_jwt_token, get_current_user


router = APIRouter()

@router.get("")
def dashboard_home():
    return {"message": "Dashboard API is accessible!"}

# WebSocket connections storage
active_connections: Dict[int, List[WebSocket]] = {}

@router.get("/projects/all", response_model=List[schemas.ProjectRead])
def get_projects(db: Session = Depends(get_db)):
    try:
        return crud.get_projects(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

# @router.post("/projects/all", response_model=schemas.ProjectRead)
# def create_project(project: schemas.ProjectCreate, db: Session = Depends(get_db)):
#     try:
#         return crud.create_project(db, project)
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

@router.post("/projects/all", response_model=schemas.ProjectRead)
def create_project(
    project: schemas.ProjectCreate, 
    current_user: models.User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    try:
        return crud.create_project(db, project, creator_id=current_user.user_id)  # Pass current user's ID
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.put("/projects/{project_id}/progress")
def update_project_progress(project_id: int, progress: float, db: Session = Depends(get_db)):
    try:
        project = crud.update_project_progress(db, project_id, progress)
        if not project:
            raise HTTPException(status_code=404, detail=f"Project with ID {project_id} not found")

        # Notify WebSocket clients about progress updates
        if project_id in active_connections:
            for connection in active_connections[project_id]:
                try:
                    connection.send_json({"project_id": project_id, "progress": progress})
                except Exception:
                    pass  # Ignore failed messages

        return {"message": "Progress updated successfully", "progress": progress}
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

# WebSocket for real-time updates
@router.websocket("/ws/progress/{project_id}")
async def websocket_endpoint(websocket: WebSocket, project_id: int):
    await websocket.accept()
    if project_id not in active_connections:
        active_connections[project_id] = []
    active_connections[project_id].append(websocket)

    try:
        while True:
            await websocket.receive_text()  # Keep connection alive
    except WebSocketDisconnect:
        active_connections[project_id].remove(websocket)
        if not active_connections[project_id]:
            del active_connections[project_id]


# Task Routes
@router.get("/tasks")
def read_tasks(db: Session = Depends(get_db)):
    try:
        return crud.get_tasks(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.post("/tasks")
def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    try:
        return crud.create_task(db, task)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    
@router.get("/projects/{project_id}/tasks")
def read_project_tasks(project_id: int, db: Session = Depends(get_db)):
    try:
        return crud.get_tasks_by_project(db, project_id)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    
@router.put("/tasks/{task_id}/category")
def update_task_category(task_id: int, category: str, db: Session = Depends(get_db)):
    try:
        task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        task.category = category
        db.commit()
        return {"message": "Category updated"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    try:
        task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        db.delete(task)
        db.commit()
        return {"message": "Task deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# User Routes
@router.get("/users")
def read_users(db: Session = Depends(get_db)):
    try:
        return crud.get_users(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.post("/users")
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    try:
        return crud.create_user(db, user)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.get("/metrics")
def get_dashboard_metrics(db: Session = Depends(get_db)):
    try:
        metrics = crud.get_dashboard_metrics(db)
        if not metrics:
            return {"message": "No metrics available"}
        return metrics
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    
# @router.get("/projects/{project_id}", response_model=schemas.ProjectRead)
# def get_project(project_id: int, db: Session = Depends(get_db)):
#     try:
#         project = db.query(models.Project).filter(models.Project.project_id == project_id).first()
#         if not project:
#             raise HTTPException(status_code=404, detail=f"Project with ID {project_id} not found")
#         return project
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

@router.get("/projects", response_model=List[schemas.ProjectRead])
def get_user_projects(current_user: models.User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        user_projects = (
            db.query(models.Project)
            .filter(
                (models.Project.creator_id == current_user.user_id) |  # Changed from .id to .user_id
                (models.Project.team_members.any(user_id=current_user.user_id))  # Changed here too
            )
            .all()
        )
        return user_projects
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    
    
@router.get("/projects/{project_id}/members", response_model=List[schemas.ProjectTeamMember])
def get_project_members(project_id: int, db: Session = Depends(get_db)):
    try:
        members = crud.get_project_team_with_users(db, project_id)
        if not members:
            raise HTTPException(
                status_code=404,
                detail=f"No members found for project {project_id}"
            )
        return members
    except HTTPException as e:
        raise e
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/assigned-tasks")
def get_assigned_tasks_for_user(
    user_data: dict = Depends(decode_jwt_token),
    db: Session = Depends(get_db)
):
    try:
        user_id = user_data["user_id"]  

        assigned_tasks = (
            db.query(models.Task)
            .join(models.UserAssignment)
            .filter(models.UserAssignment.user_id == user_id)
            .all()
        )

        return [
            {
                "title": t.title,
                "category": t.category,
                "due_date": t.due_date.isoformat() if t.due_date else "N/A",
                "priority": t.priority,
                "progress": t.progress,
            }
            for t in assigned_tasks
        ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@router.get("/upcoming-deadlines")
def get_upcoming_deadlines(
    db: Session = Depends(get_db),
    user_data: dict = Depends(decode_jwt_token)
):
    user_id = user_data["user_id"]

    tasks = (
        db.query(models.Task)
        .join(models.UserAssignment, models.Task.task_id == models.UserAssignment.task_id)
        .filter(
            models.UserAssignment.user_id == user_id,
            models.Task.due_date != None  # ensure task has a due date
        )
        .order_by(models.Task.due_date.asc())  # soonest first
        .limit(5)  # return top 5 upcoming
        .all()
    )

    return [
        {
            "title": task.title,
            "due_date": task.due_date.isoformat(),
            "priority": task.priority,
            "category": task.category,
            "project_id": task.project_id
        }
        for task in tasks
    ]

