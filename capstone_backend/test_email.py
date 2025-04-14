import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from datetime import datetime
import crud, models

# Use an in-memory SQLite database for testing
DATABASE_URL = "sqlite:///:memory:"
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture
def db():
    """Fixture to create a new database session for each test."""
    models.Base.metadata.create_all(bind=engine)
    session = SessionLocal()
    yield session
    session.close()

def test_create_invite(db):
    """Test if an invite is created successfully"""
    email = "testuser@example.com"
    project_id = 1

    invite = crud.create_invite(db, project_id, email)
    
    assert invite.email == email
    assert invite.status == "Pending"
    assert invite.token is not None

def test_accept_invite(db):
    """Test if a user can accept an invite"""
    email = "testuser@example.com"
    project_id = 1

    # Create a test user
    user = models.User(first_name="Test", last_name="User", email=email, phone_no="1234567890", password="password")
    db.add(user)
    db.commit()

    # Create an invite
    invite = crud.create_invite(db, project_id, email)
    
    # Accept the invite
    accepted_invite = crud.accept_invite(db, invite, user.user_id)

    assert accepted_invite.status == "Accepted"
    assert accepted_invite.accepted_at is not None

    # Check if user is added to project
    project_team = db.query(models.ProjectTeam).filter_by(project_id=project_id, user_id=user.user_id).first()
    assert project_team is not None

