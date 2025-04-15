from sqlalchemy.orm import Session
import schemas
import models
from passlib.context import CryptContext
from sqlalchemy import func
import jwt
from datetime import datetime
from sqlalchemy.orm import joinedload
import uuid

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

def create_user(db: Session, user: schemas.UserCreate):
    try:
        hashed_password = hash_password(user.password)
        db_user = models.User(
            first_name=user.first_name,
            last_name=user.last_name,
            email=user.email,
            phone_no=user.phone_no,
            password=hashed_password,
        )
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user
    except Exception as e:
        db.rollback()
        raise Exception(f"Error creating user: {str(e)}")

def authenticate_user(db: Session, email: str, password: str):
    try:
        user = db.query(models.User).filter(models.User.email == email).first()
        if not user or not verify_password(password, user.password):
            return None
        return user
    except Exception as e:
        raise Exception(f"Authentication error: {str(e)}")
    
def get_user_by_email(db: Session, email: str):
    try:
        return db.query(models.User).filter(models.User.email == email).first()
    except Exception as e:
        raise Exception(f"Error fetching user by email: {str(e)}")
    
def get_user_by_id(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.user_id == user_id).first()

def update_user(db: Session, user_id: int, user_update: schemas.UserUpdate):
    user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if not user:
        return None

    for field, value in user_update.dict(exclude_unset=True).items():
        setattr(user, field, value)

    db.commit()
    db.refresh(user)
    return user

    
def get_project(db: Session, project_id: int):
    return db.query(models.Project).filter(models.Project.project_id == project_id).first()

def get_projects(db: Session):
    try:
        return db.query(models.Project).all()  # Get ALL projects
    except Exception as e:
        raise Exception(f"Error fetching projects: {str(e)}")
    

def create_project(db: Session, project: schemas.ProjectCreate, creator_id: int):  # Add creator_id parameter
    try:
        new_project = models.Project(
            title=project.title,
            project_description=project.project_description,
            workspace=project.workspace,
            team_count=project.team_count,
            progress=project.progress,
            creator_id=creator_id  # Set the creator
        )
        db.add(new_project)
        db.commit()
        db.refresh(new_project)
        return new_project
    except Exception as e:
        db.rollback()
        raise Exception(f"Error creating project: {str(e)}")

def update_project_progress(db: Session, project_id: int, progress: float):
    try:
        project = db.query(models.Project).filter(models.Project.project_id == project_id).first()
        if not project:
            raise Exception(f"Project with ID {project_id} not found")
        project.progress = progress
        db.commit()
        db.refresh(project)
        return project
    except Exception as e:
        db.rollback()
        raise Exception(f"Error updating project progress: {str(e)}")

# CRUD for Tasks
def get_tasks(db: Session):
    try:
        return db.query(models.Task).all()
    except Exception as e:
        raise Exception(f"Error fetching tasks: {str(e)}")
    
# def get_tasks_by_project(db: Session, project_id: int):
#     return db.query(models.Task).filter(models.Task.project_id == project_id).all()

def get_tasks_by_project(db: Session, project_id: int):
    tasks = db.query(models.Task).filter(models.Task.project_id == project_id).all()

    results = []
    for task in tasks:
        assignment = (
            db.query(models.UserAssignment)
            .filter(models.UserAssignment.task_id == task.task_id)
            .first()
        )

        assigned_user = None
        if assignment:
            user = db.query(models.User).filter(models.User.user_id == assignment.user_id).first()
            if user:
                assigned_user = f"{user.first_name} {user.last_name}"

        results.append({
            "task_id": task.task_id,
            "title": task.title,
            "priority": task.priority,
            "category": task.category,
            "created_at": task.created_at,
            "assigned_to": assigned_user or "Unassigned"
        })

    return results

# def create_task(db: Session, task: schemas.TaskCreate):
#     try:
#         db_task = models.Task(
#             title=task.title, 
#             category=task.category, 
#             due_date=task.due_date, 
#             priority=task.priority, 
#             progress=0.0, 
#             project_id=task.project_id
#         )
#         db.add(db_task)
#         db.commit()
#         db.refresh(db_task)
#         return db_task
    
#     assignment = models.UserAssignment(
#         task_id=db_task.task_id,
#          user_id=task.assigned_to  # 👈 this comes from frontend
#     )
#     db.add(assignment)
#     db.commit()
        
#         return db_task

#     except Exception as e:
#         db.rollback()
#         raise Exception(f"Error creating task: {str(e)}")


def create_task(db: Session, task: schemas.TaskCreate):
    try:
        # 1. Create the task
        db_task = models.Task(
            title=task.title,
            category=task.category,
            due_date=task.due_date,
            priority=task.priority,
            progress=0.0,
            project_id=task.project_id
        )
        db.add(db_task)
        db.commit()
        db.refresh(db_task)

        # ✅ 2. Assign the task to the user
        assignment = models.UserAssignment(
            task_id=db_task.task_id,
            user_id=task.assigned_to  # 👈 this comes from frontend
        )
        db.add(assignment)
        db.commit()

        return db_task

    except Exception as e:
        db.rollback()
        raise Exception(f"Error creating task: {str(e)}")


# CRUD for Users
def get_users(db: Session):
    try:
        return db.query(models.User).all()
    except Exception as e:
        raise Exception(f"Error fetching users: {str(e)}")

# # Dashboard metrics
# def get_dashboard_metrics(db: Session):
#     try:
#         metrics = {}
        
#         # Get total projects
#         metrics["total_projects"] = db.query(func.count(models.Project.project_id)).scalar() or 0
        
#         # Get total tasks
#         metrics["total_tasks"] = db.query(func.count(models.Task.task_id)).scalar() or 0
        
#         # Get total users
#         metrics["total_users"] = db.query(func.count(models.User.user_id)).scalar() or 0
        
#         # Get average project progress
#         avg_progress = db.query(func.avg(models.Project.progress)).scalar()
#         metrics["average_project_progress"] = float(avg_progress) if avg_progress is not None else 0.0
        
#         # Get tasks by priority
#         priority_counts = db.query(
#             models.Task.priority, 
#             func.count(models.Task.task_id)
#         ).group_by(models.Task.priority).all()
        
#         metrics["tasks_by_priority"] = {
#             priority: count for priority, count in priority_counts
#         }
        
#         return metrics
#     except Exception as e:
#         raise Exception(f"Error getting dashboard metrics: {str(e)}")

def get_dashboard_metrics(db: Session, current_user: models.User):
    try:
        user_id = current_user.user_id
        metrics = {}

        # Projects where user is creator or member
        user_projects = db.query(models.Project).filter(
            (models.Project.creator_id == user_id) |
            (models.Project.team_members.any(user_id=user_id))
        ).all()

        project_ids = [p.project_id for p in user_projects]

        # Total projects
        metrics["total_projects"] = len(project_ids)

        # Total tasks for those projects
        metrics["total_tasks"] = db.query(models.Task).filter(
            models.Task.project_id.in_(project_ids)
        ).count()

        # Total users in the team across those projects (unique count)
        team_user_ids = set()
        for p in user_projects:
            for member in p.team_members:
                team_user_ids.add(member.user_id)
        metrics["total_users"] = len(team_user_ids)

        # Average project progress
        if user_projects:
            avg_progress = sum([p.progress for p in user_projects]) / len(user_projects)
        else:
            avg_progress = 0
        metrics["average_project_progress"] = round(avg_progress, 2)

        # Tasks by priority (for user's projects)
        priority_counts = db.query(
            models.Task.priority, func.count(models.Task.task_id)
        ).filter(models.Task.project_id.in_(project_ids))\
         .group_by(models.Task.priority).all()
        metrics["tasks_by_priority"] = {priority: count for priority, count in priority_counts}

        # Assigned tasks (only for current user) - using UserAssignment
        metrics["assigned_tasks"] = db.query(models.UserAssignment).filter(
            models.UserAssignment.user_id == user_id
        ).count()

        # Overdue tasks (user assigned)
        now = datetime.utcnow()
        metrics["overdue_tasks"] = db.query(models.Task)\
            .join(models.UserAssignment)\
            .filter(
                models.UserAssignment.user_id == user_id,
                models.Task.due_date < now,
                models.Task.category != "Completed"
            ).count()

        # Completed tasks (user assigned)
        metrics["completed_tasks"] = db.query(models.Task)\
            .join(models.UserAssignment)\
            .filter(
                models.UserAssignment.user_id == user_id,
                models.Task.category == "Completed"
            ).count()

        return metrics
    except Exception as e:
        raise Exception(f"Error getting dashboard metrics: {str(e)}")

    
def assign_user_to_task(db: Session, task_id: int, user_id: int):
    task = db.query(models.Task).filter(models.Task.task_id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")

    user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Check if the user is already assigned
    existing_assignment = db.query(models.UserAssignments).filter(
        models.UserAssignments.task_id == task_id,
        models.UserAssignments.user_id == user_id
    ).first()

    if existing_assignment:
        raise HTTPException(status_code=400, detail="User already assigned")

    # Assign the user
    new_assignment = models.UserAssignments(task_id=task_id, user_id=user_id)
    db.add(new_assignment)
    db.commit()
    
    return {"message": "User assigned to task"}

def create_invite(db: Session, project_id: int, email: str):
    token = str(uuid.uuid4())
    invite = models.ProjectInvitation(
        project_id=project_id,  # Ensure project_id is stored
        email=email,
        token=token,
        status="Pending"
    )
    db.add(invite)
    db.commit()
    db.refresh(invite)
    return invite


def get_invite_by_token(db: Session, token: str):
    return db.query(models.ProjectInvitation).filter(models.ProjectInvitation.token == token).first()

def accept_invite(db: Session, invite: models.ProjectInvitation, user_id: int):
    invite.status = "Accepted"
    invite.accepted_at = datetime.utcnow()

    # Add user to the project team
    team_member = models.ProjectTeam(project_id=invite.project_id, user_id=user_id)
    db.add(team_member)
    
    db.commit()
    db.refresh(invite)
    return invite


def get_project_team_with_users(db: Session, project_id: int):
    try:
        team_members = db.query(
            models.User.user_id,
            models.ProjectTeam.project_team_id,
            models.User.first_name,
            models.User.last_name,
            models.ProjectTeam.joined_at
        ).join(
            models.ProjectTeam,
            models.User.user_id == models.ProjectTeam.user_id
        ).filter(
            models.ProjectTeam.project_id == project_id
        ).all()
        
        return [
            {
                "full_name": f"{member.first_name} {member.last_name}",
                "joined_at": member.joined_at,
                "user_id": member.user_id,
                "project_team_id": member.project_team_id
            }
            for member in team_members
        ]
    except Exception as e:
        raise Exception(f"Error fetching project team: {str(e)}")

