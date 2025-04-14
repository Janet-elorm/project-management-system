from sqlalchemy import Column, Integer, String, DECIMAL, ForeignKey, Enum, DateTime, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from db import Base  # Import the Base from your db connection


# class Project(Base):
#     __tablename__ = "Projects"

#     project_id = Column(Integer, primary_key=True, autoincrement=True)
#     title = Column(String(255), nullable=False)
#     project_description = Column(String(200), nullable=True)  # Correct field name
#     workspace = Column(String(255), nullable=True)
#     team_count = Column(Integer, nullable=True)
#     progress = Column(DECIMAL(5, 2), nullable=True)
#     creator_id = Column(Integer, ForeignKey("Users.user_id"))
#     created_at = Column(DateTime, server_default=func.now())  # Fixed

#     tasks = relationship("Task", back_populates="project")
#     team_members = relationship("ProjectTeam", back_populates="project")
#     creator = relationship("User", back_populates="projects")

class Project(Base):
    __tablename__ = "Projects"

    project_id = Column(Integer, primary_key=True, autoincrement=True)
    title = Column(String(255), nullable=False)
    project_description = Column(String(200), nullable=True)
    workspace = Column(String(255), nullable=True)
    team_count = Column(Integer, nullable=True)
    progress = Column(DECIMAL(5, 2), nullable=True)
    creator_id = Column(Integer, ForeignKey("Users.user_id"))
    created_at = Column(DateTime, server_default=func.now())

    tasks = relationship("Task", back_populates="project")
    team_members = relationship("ProjectTeam", back_populates="project")
    creator = relationship("User", back_populates="created_projects")  # Note the back_populates name

# class User(Base):
#     __tablename__ = "Users"

#     user_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
#     first_name = Column(String(50), nullable=False)  # Added
#     last_name = Column(String(50), nullable=False)   # Added
#     email = Column(String(100), unique=True, nullable=False)  # Fixed size
#     phone_no = Column(String(15), unique=True, nullable=False)  # Added
#     password = Column(String(255), nullable=False)  # Added for authentication
#     profile_picture = Column(String(255), nullable=True)  # Store image URL
#     created_at = Column(DateTime, server_default=func.now())

#     assignments = relationship("UserAssignment", back_populates="user")
#     projects = relationship("ProjectTeam", back_populates="user")
#     projects = relationship("Project", back_populates="creator")

class User(Base):
    __tablename__ = "Users"

    user_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    phone_no = Column(String(15), unique=True, nullable=False)
    password = Column(String(255), nullable=False)
    profile_picture = Column(String(255), nullable=True)
    created_at = Column(DateTime, server_default=func.now())

    # Tasks assigned to this user
    assignments = relationship("UserAssignment", back_populates="user")
    
    # Projects where this user is a team member
    project_teams = relationship("ProjectTeam", back_populates="user")
    
    # Projects created by this user
    created_projects = relationship("Project", back_populates="creator")
    


class Task(Base):
    __tablename__ = "Tasks"

    task_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("Projects.project_id", ondelete="CASCADE"), index=True)  # Indexed + CASCADE
    title = Column(String(255), nullable=False)
    category = Column(String(255))
    due_date = Column(Date)
    priority = Column(Enum("High", "Medium", "Low", name="priority_enum"), nullable=False)
    progress = Column(DECIMAL(5, 2))
    created_at = Column(DateTime, server_default=func.now())  # Fixed

    project = relationship("Project", back_populates="tasks")
    assignments = relationship("UserAssignment", back_populates="task")


class UserAssignment(Base):
    __tablename__ = "UserAssignments"

    assignment_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    task_id = Column(Integer, ForeignKey("Tasks.task_id", ondelete="CASCADE"), index=True)  # Indexed + CASCADE
    user_id = Column(Integer, ForeignKey("Users.user_id", ondelete="CASCADE"), index=True)  # Indexed + CASCADE
    assigned_at = Column(DateTime, server_default=func.now())  # Fixed

    task = relationship("Task", back_populates="assignments")
    user = relationship("User", back_populates="assignments")


# class ProjectTeam(Base):
#     __tablename__ = "ProjectTeam"

#     project_team_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
#     project_id = Column(Integer, ForeignKey("Projects.project_id", ondelete="CASCADE"), index=True)
#     user_id = Column(Integer, ForeignKey("Users.user_id", ondelete="CASCADE"), index=True)
#     joined_at = Column(DateTime, server_default=func.now())

#     project = relationship("Project", back_populates="team_members")
#     user = relationship("User", back_populates="project_teams")  # Updated to match new name

class ProjectTeam(Base):
    __tablename__ = "ProjectTeam"

    project_team_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("Projects.project_id", ondelete="CASCADE"), index=True)
    user_id = Column(Integer, ForeignKey("Users.user_id", ondelete="CASCADE"), index=True)
    joined_at = Column(DateTime, server_default=func.now())

    project = relationship("Project", back_populates="team_members")
    user = relationship("User", back_populates="project_teams")

class DashboardMetric(Base):
    __tablename__ = "DashboardMetrics"

    metric_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    total_projects = Column(Integer, default=0)
    total_tasks = Column(Integer, default=0)
    assigned_tasks = Column(Integer, default=0)
    overdue_tasks = Column(Integer, default=0)
    completed_tasks = Column(Integer, default=0)
    metric_date = Column(Date, unique=True)
    created_at = Column(DateTime, server_default=func.now())  # Fixed
    
    
    
class ProjectInvitation(Base):
    __tablename__ = "project_invitations"

    invitation_id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    project_id = Column(Integer, ForeignKey("Projects.project_id"), nullable=False)  # Add this line
    email = Column(String, nullable=False)
    token = Column(String, unique=True, nullable=False)
    status = Column(Enum("Pending", "Accepted", "Declined"), default="Pending")
    created_at = Column(DateTime, server_default=func.now()) 
    accepted_at = Column(DateTime, nullable=True)  # Remove server_default here
    
    
    

