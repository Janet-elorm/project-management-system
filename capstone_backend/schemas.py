from pydantic import BaseModel, EmailStr, HttpUrl
from typing import Optional, List
from datetime import datetime, date
from decimal import Decimal


# Schema for creating a project
class ProjectCreate(BaseModel):
    title: str
    project_description: Optional[str] = None 
    workspace: Optional[str] = None
    team_count: Optional[int] = None
    progress: Optional[float] = None
    due_date: Optional[date] = None


# Schema for reading a project from the database
# class ProjectRead(ProjectCreate):
#     project_id: int
#     created_at: datetime

    class Config:
        from_attributes = True

# Schema for creating a task
class TaskCreate(BaseModel):
    project_id: int
    title: str
    category: Optional[str] = None
    due_date: Optional[datetime] = None
    priority: Optional[str] = "Medium"
    progress: Optional[Decimal] = Decimal("0.00")
    assigned_to: int

# Schema for reading a task
class TaskRead(TaskCreate):
    task_id: int
    created_at: datetime

    class Config:
        from_attributes = True
        
class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    progress: Optional[float] = None
    due_date: Optional[str] = None  # format: 'YYYY-MM-DD'


# Schema for creating a user
class UserCreate(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone_no: str
    password: str  # Added password field
    
class UserResponse(BaseModel):
    user_id: int
    first_name: str
    last_name: str
    email: EmailStr
    phone_no: str
    profile_picture: Optional[HttpUrl] = None  # Image URL

    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    phone_no: Optional[str] = None
    profile_picture: Optional[str] = None  # Image URL

# Schema for reading a user
class UserRead(UserCreate):
    user_id: int
    created_at: datetime

    class Config:
        from_attributes = True

# Schema for user login
class UserLogin(BaseModel):
    email: EmailStr
    password: str

# Schema for User Assignments
class UserAssignmentCreate(BaseModel):
    task_id: int
    user_id: int

class UserAssignmentRead(UserAssignmentCreate):
    assignment_id: int
    assigned_at: datetime

    class Config:
        from_attributes = True

# Schema for Project Team
class ProjectTeamCreate(BaseModel):
    project_id: int
    user_id: int

class ProjectTeamRead(ProjectTeamCreate):
    project_team_id: int
    joined_at: datetime

    class Config:
        from_attributes = True
        
        
class ProjectTeamMember(BaseModel):
    full_name: str  
    joined_at: datetime
    user_id: int 
    project_team_id: int  
    
    class Config:
        from_attributes = True

# Schema for Dashboard Metrics
class DashboardMetricRead(BaseModel):
    metric_id: int
    total_projects: int
    total_tasks: int
    assigned_tasks: int
    overdue_tasks: int
    completed_tasks: int
    metric_date: datetime
    created_at: datetime

    class Config:
        from_attributes = True

class InviteCreate(BaseModel):
    email: EmailStr

class InviteResponse(BaseModel):
    invitation_id: int
    project_id: int
    email: EmailStr
    status: str
    created_at: datetime
    accepted_at: Optional[datetime] = None

    class Config:
        from_attributes = True
        
class ProjectRead(BaseModel):
    project_id: int
    title: str
    project_description: Optional[str] = None
    workspace: Optional[str] = None
    team_count: Optional[int] = None
    progress: Optional[float] = None
    creator_name: Optional[str] = None
    creator_id: Optional[int] = None

    class Config:
        from_attributes = True

class TaskCreateWithAssignments(BaseModel):
    title: str
    category: Optional[str] = None
    due_date: Optional[str] = None 
    priority: str
    user_ids: List[int]  # 👈 users to assign