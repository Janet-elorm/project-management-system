from fastapi import APIRouter, Depends, HTTPException, File, UploadFile, Request, Security
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session
import crud, schemas, models
from db import get_db
import shutil
import os
import jwt
import datetime
from jose import JWTError


# Router
auth_router = APIRouter()

# JWT Configuration
SECRET_KEY = "your_secret_key"  # Change this to a secure key
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 300

# OAuth2 Scheme for Authentication
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="login")

# Directory for Profile Pictures
UPLOAD_DIR = "profile_pictures"
os.makedirs(UPLOAD_DIR, exist_ok=True)


# 🔹 Function to Generate JWT Token
def create_jwt_token(data: dict, expires_delta: int = ACCESS_TOKEN_EXPIRE_MINUTES):
    to_encode = data.copy()
    expire = datetime.datetime.utcnow() + datetime.timedelta(minutes=expires_delta)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


# 🔹 Function to Decode JWT & Get User ID
def decode_jwt_token(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):

    """Decode JWT token and return user details."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("user_id")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token")

        user = db.query(models.User).filter(models.User.user_id == user_id).first()
        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Return full user details
        return {"user_id": user.user_id, "email": user.email}

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")


# 🔹 User Signup Route
@auth_router.post("/signup", response_model=schemas.UserRead)
def signup(user: schemas.UserCreate, db: Session = Depends(get_db)):
    existing_user = crud.get_user_by_email(db, user.email)
    if existing_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db, user)


# 🔹 Login Route (Returns JWT Token)
@auth_router.post("/login")
def login(user: schemas.UserLogin, db: Session = Depends(get_db)):
    authenticated_user = crud.authenticate_user(db, user.email, user.password)
    if not authenticated_user:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    # Generate JWT Token
    token_data = {"user_id": authenticated_user.user_id, "email": authenticated_user.email}
    token = create_jwt_token(token_data)

    return {"access_token": token, "token_type": "bearer"}


@auth_router.get("/me")
def get_current_user(user_data: dict = Depends(decode_jwt_token), db: Session = Depends(get_db)):
    print("🔍 user_data from token:", user_data)

    user = crud.get_user_by_id(db, user_data["user_id"])
    if not user:
        raise HTTPException(status_code=404, detail="User not found")



    return {
        "user_id": user.user_id,
        "first_name": user.first_name,
        "last_name": user.last_name,
        "email": user.email,
        "profile_picture": user.profile_picture
        
        
    }

# In your auth.py
def get_current_user(
    user_data: dict = Depends(decode_jwt_token),
    db: Session = Depends(get_db)
) -> models.User:
    # Use dictionary access instead of attribute access
    user_id = user_data.get("user_id")
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# 🔹 Update User Profile (Uses JWT)
@auth_router.put("/me/update")
def update_profile(
    user_update: schemas.UserUpdate,
    user_id: int = Depends(decode_jwt_token),
    db: Session = Depends(get_db)
):
    updated_user = crud.update_user(db, user_id, user_update)
    if not updated_user:
        raise HTTPException(status_code=404, detail="User not found")

    return {"message": "Profile updated successfully", "user": updated_user}





# 🔹 Get Any User by ID (For Admins or Public)
@auth_router.get("/users/{user_id}", response_model=schemas.UserRead)
def get_user(user_id: int, db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.user_id == user_id).first()
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


# 🔹 Upload Profile Picture (Uses JWT)
@auth_router.post("/users/upload-profile-picture")
def upload_profile_picture(
    file: UploadFile = File(...),
    user_id: int = Depends(decode_jwt_token),
    db: Session = Depends(get_db)
):
    user = crud.get_user_by_id(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    file_path = f"{UPLOAD_DIR}/{user_id}_{file.filename}"
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    user.profile_picture = file_path
    db.commit()
    db.refresh(user)

    return {"message": "Profile picture uploaded successfully", "profile_picture_url": file_path}


# 🔹 Get All Users (Optional)
@auth_router.get("/users/", response_model=list[schemas.UserRead])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = db.query(models.User).offset(skip).limit(limit).all()
    return users

