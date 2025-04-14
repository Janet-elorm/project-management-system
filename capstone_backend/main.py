from fastapi import FastAPI, Depends
from routes.auth import auth_router 
from routes.dashboard import router as dashboard_router
from routes.invite import invite_router
from db import Base, engine
from fastapi.middleware.cors import CORSMiddleware
from starlette.middleware.sessions import SessionMiddleware
from fastapi.openapi.models import OAuthFlows as OAuthFlowsModel
from fastapi.openapi.models import OAuthFlowPassword
from fastapi.security import OAuth2PasswordBearer


# Create tables
Base.metadata.create_all(bind=engine)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")  


app = FastAPI(title="Project Management API")


@app.get("/protected-endpoint")
async def protected(token: str = Depends(oauth2_scheme)):
    return {"token": token}

# Add CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix="/auth", tags=["Authentication"])
app.include_router(dashboard_router, prefix="/dashboard", tags=["Dashboard"])
app.include_router(invite_router, prefix="/invite", tags=["Invitation"])

@app.get("/")
def home():
    return {"message": "Project Management API is running!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}