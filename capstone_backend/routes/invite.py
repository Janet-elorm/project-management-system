from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
import crud, models, schemas
from db import get_db
from email_sender import send_invite_email
from routes.auth import decode_jwt_token
from datetime import datetime
import os


invite_router = APIRouter()

@invite_router.post("/projects/{project_id}/invite")
def invite_user(
    project_id: int,
    invite: schemas.InviteCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(decode_jwt_token)
):
    # Ensure project exists
    project = db.query(models.Project).filter(models.Project.project_id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    # Ensure the invited user is not already in the project
    invited_user = crud.get_user_by_email(db, invite.email)
    if not invited_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    existing_team_member = (
        db.query(models.ProjectTeam)
        .filter(models.ProjectTeam.project_id == project_id, models.ProjectTeam.user_id == invited_user.user_id)
        .first()
        )
    
    if existing_team_member:
        raise HTTPException(status_code=400, detail="Invited user is already part of the project")
    
    invite_entry = crud.create_invite(db, project_id, invite.email)

    # Generate invite link
    invite_link = f"http://34.123.72.43:8000/projects/accept-invite?token={invite_entry.token}&projectId={project_id}"


    # Send email
    sender_email = os.getenv("SMTP_EMAIL")
    sender_password = os.getenv("SMTP_PASSWORD")
    send_invite_email(db, sender_email, sender_password, invite.email, project_id, invite_link)

    return {"message": "Invitation sent successfully"}


@invite_router.get("/projects/accept-invite")
def accept_invite(token: str, db: Session = Depends(get_db)):
    invite = crud.get_invite_by_token(db, token)
    if not invite or invite.status != "Pending":
        raise HTTPException(status_code=404, detail="Invalid or expired invitation")

    # ✅ Extract user email from invite and find user
    user = crud.get_user_by_email(db, invite.email)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # ✅ Accept the invitation
    accepted_invite = crud.accept_invite(db, invite, user.user_id)

    return {"message": "You have successfully joined the project"}

@invite_router.post("/projects/{project_id}/add_member")
def add_member_to_project(
    project_id: int,
    user_id: int,
    db: Session = Depends(get_db)
):
    project = db.query(models.Project).filter(models.Project.project_id == project_id).first()
    user = db.query(models.User).filter(models.User.user_id == user_id).first()

    if not project or not user:
        raise HTTPException(status_code=404, detail="Project or user not found")

    # Prevent duplicates
    existing = db.query(models.ProjectTeam).filter_by(project_id=project_id, user_id=user_id).first()
    if existing:
        raise HTTPException(status_code=400, detail="User already in project")

    new_assignment = models.ProjectTeam(project_id=project_id, user_id=user_id)
    db.add(new_assignment)
    db.commit()
    return {"message": "User added to project"}
