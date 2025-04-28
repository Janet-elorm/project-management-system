from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, HTTPException
from sqlalchemy.orm import Session
from db import get_db
import models, schemas, crud
from typing import List, Dict
from routes.auth import decode_jwt_token, get_current_user
from sqlalchemy.orm import joinedload
from crud import project_to_dict
from fastapi.encoders import jsonable_encoder
from crud import update_project_progress  
from schemas import TaskUpdate, TaskCreateWithAssignments  # make sure you import it
from fastapi import BackgroundTasks

router = APIRouter()

@router.get("")
def dashboard_home():
    return {"message": "Dashboard API is accessible!"}

# WebSocket connections storage
active_connections: Dict[int, List[WebSocket]] = {}

@router.get("/projects/all")
def get_projects(db: Session = Depends(get_db)):
    try:
        projects = db.query(models.Project).options(joinedload(models.Project.creator)).all()
        return [project_to_dict(p) for p in projects]
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
    
# @router.put("/tasks/{task_id}/category")
# def update_task_category(task_id: int, category: str, db: Session = Depends(get_db)):
#     try:
#         task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
#         if not task:
#             raise HTTPException(status_code=404, detail="Task not found")

#         task.category = category
#         if category == "Completed":
#             task.progress = 1.0  # ✅ Ensure progress reflects completion

#         db.commit()
#         return {"message": "Category updated"}
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

@router.put("/tasks/{task_id}/category")
async def update_task_category(
    task_id: int,
    category: str,
    db: Session = Depends(get_db),
):
    try:
        task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        task.category = category
        if category == "Completed":
            task.progress = 1.0  # ✅ reflect progress

        db.commit()

        # 🛠 Recalculate project progress
        tasks = db.query(models.Task).filter(models.Task.project_id == task.project_id).all()
        if tasks:
            completed = sum(1 for t in tasks if t.progress is not None and t.progress >= 0.99)
            project_progress = completed / len(tasks)

            # 🛠 Now broadcast!
            await broadcast_progress_update(task.project_id, project_progress)

        return {"message": "Category updated"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/projects/{project_id}/calculate_progress")
def calculate_project_progress(project_id: int, db: Session = Depends(get_db)):
    tasks = db.query(models.Task).filter(models.Task.project_id == project_id).all()

    if not tasks:
        return {"progress": 0.0}

    completed = sum(1 for task in tasks if task.category == "Completed")
    progress = completed / len(tasks)

    return {
        "project_id": project_id,
        "progress": round(progress, 2)  # returns value like 0.25, 0.5 etc.
    }


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
            

async def broadcast_progress_update(project_id: int, progress: float):
    if project_id in active_connections:
        data = jsonable_encoder({
            "project_id": project_id,
            "progress": round(progress, 2)
        })
        for ws in active_connections[project_id]:
            await ws.send_json(data)
            




@router.get("/tasks")
def read_tasks(db: Session = Depends(get_db)):
    try:
        return crud.get_tasks(db)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    

@router.post("/projects/{project_id}/tasks")
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
    
@router.put("/tasks/{task_id}")
async def update_task(task_id: int, updated_data: TaskUpdate, db: Session = Depends(get_db)):
    try:
        task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        # Update task fields
        if updated_data.title is not None:
            task.title = updated_data.title
        if updated_data.description is not None:
            task.description = updated_data.description
        if updated_data.progress is not None:
            task.progress = updated_data.progress
        if updated_data.due_date is not None:
            task.due_date = updated_data.due_date

        db.commit()
        db.refresh(task)

        # Recalculate project progress
        tasks = db.query(models.Task).filter(models.Task.project_id == task.project_id).all()
        if tasks:
            completed = sum(1 for t in tasks if t.progress is not None and t.progress >= 0.99)
            project_progress = completed / len(tasks)

            await update_project_progress(db, task.project_id, project_progress)

        return {"message": "Task updated successfully"}

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    
@router.delete("/tasks/{task_id}")
async def delete_task(task_id: int, db: Session = Depends(get_db)):
    try:
        task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Task not found")

        project_id = task.project_id  # capture before delete
        db.delete(task)
        db.commit()

        # Recalculate progress after deletion
        tasks = db.query(models.Task).filter(models.Task.project_id == project_id).all()
        completed = sum(1 for t in tasks if t.progress is not None and t.progress >= 0.99)
        project_progress = completed / len(tasks) if tasks else 0.0

        from .crud import update_project_progress
        await update_project_progress(db, project_id, project_progress)

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
    

# @router.get("/metrics")
# def get_dashboard_metrics(db: Session = Depends(get_db)):
#     try:
#         metrics = crud.get_dashboard_metrics(db)
#         if not metrics:
#             return {"message": "No metrics available"}
#         return metrics
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))

@router.get("/metrics")
def get_dashboard_metrics(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        return crud.get_dashboard_metrics(db, current_user)
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

@router.get("/projects/user", response_model=List[schemas.ProjectRead])
def get_user_projects(
    current_user: models.User = Depends(get_current_user), 
    db: Session = Depends(get_db)
):
    try:
        projects = (
            db.query(models.Project)
            .options(joinedload(models.Project.creator))
            .filter(
                (models.Project.creator_id == current_user.user_id) |
                (models.Project.team_members.any(user_id=current_user.user_id))
            )
            .all()
        )
        return [project_to_dict(p) for p in projects]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
    
@router.get("/projects/{project_id}", response_model=List[schemas.ProjectRead])
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




    
@router.get("/projects/single/{project_id}", response_model=schemas.ProjectRead)
def get_project_by_id(
    project_id: int, 
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)  # Add authentication
):
    project = db.query(models.Project).filter(models.Project.project_id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    
    # Optional: Verify user has access to this project
    if not (project.creator_id == current_user.user_id or 
            any(member.user_id == current_user.user_id for member in project.team_members)):
        raise HTTPException(status_code=403, detail="Not authorized to access this project")
    
    return project


    
    
# @router.get("/projects/{project_id}/members", response_model=List[schemas.ProjectTeamMember])
# def get_project_members(project_id: int, db: Session = Depends(get_db)):
#     try:
#         members = crud.get_project_team_with_users(db, project_id)
#         if not members:
#             raise HTTPException(
#                 status_code=404,
#                 detail=f"No members found for project {project_id}"
#             )
#         return members
#     except HTTPException as e:
#         raise e
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=str(e))


@router.get("/projects/{project_id}/members")
def get_project_members(project_id: int, db: Session = Depends(get_db)):
    try:
        # Fetch team members for the project
        team_members = (
            db.query(models.User)
            .join(models.ProjectTeam, models.ProjectTeam.user_id == models.User.user_id)
            .filter(models.ProjectTeam.project_id == project_id)
            .all()
        )

        result = []
        for user in team_members:
            # Get all tasks assigned to this user within the project
            assigned_tasks = (
                db.query(models.Task)
                .join(models.UserAssignment, models.UserAssignment.task_id == models.Task.task_id)
                .filter(
                    models.UserAssignment.user_id == user.user_id,
                    models.Task.project_id == project_id
                )
                .all()
            )

            completed_count = sum(1 for task in assigned_tasks if task.progress >= 0.99)

            result.append({
                "full_name": f"{user.first_name} {user.last_name}",
                "email": user.email,
                "assigned_tasks": len(assigned_tasks),
                "completed_tasks": completed_count
            })

        return result

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
    
    
# @router.post("/tasks/{task_id}/assign")
# def assign_user_to_task(
#     task_id: int,
#     user_id: int,
#     db: Session = Depends(get_db)
# ):
#     task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
#     user = db.query(models.User).filter(models.User.user_id == user_id).first()

#     if not task or not user:
#         raise HTTPException(status_code=404, detail="Task or user not found")

#     # Prevent duplicate assignments
#     existing = db.query(models.UserAssignment).filter_by(
#         task_id=task_id, user_id=user_id
#     ).first()
#     if existing:
#         raise HTTPException(status_code=400, detail="User already assigned to task")

#     assignment = models.UserAssignment(task_id=task_id, user_id=user_id)
#     db.add(assignment)
#     db.commit()

#     return {"message": f"User {user_id} successfully assigned to task {task_id}"}

@router.post("/projects/{project_id}/tasks/assign")
def create_task_with_assignments(
    project_id: int,
    task_data: TaskCreateWithAssignments,
    db: Session = Depends(get_db)
):
    # ✅ Create the task
    new_task = models.Task(
        title=task_data.title,
        category=task_data.category,
        due_date=task_data.due_date,
        priority=task_data.priority,
        project_id=project_id,
        progress=0.0
    )
    db.add(new_task)
    db.commit()
    db.refresh(new_task)

    # ✅ Assign users
    results = {"assigned": [], "skipped": []}
    for user_id in task_data.user_ids:
        user = db.query(models.User).filter(models.User.user_id == user_id).first()
        if not user:
            results["skipped"].append({"user_id": user_id, "reason": "User not found"})
            continue

        assignment = models.UserAssignment(task_id=new_task.task_id, user_id=user_id)
        db.add(assignment)
        results["assigned"].append(user_id)

    db.commit()

    return {
        "message": "Task created and users assigned",
        "task_id": new_task.task_id,
        "details": results
    }
