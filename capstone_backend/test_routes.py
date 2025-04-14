# from main import app

# print("Registered routes:")
# for route in app.routes:
#     if hasattr(route, "methods"):
#         print(f"{route.path} -> {route.methods}")
#     else:
#         print(f"{route.path} (WebSocket or other non-HTTP route)")
from fastapi import Depends, HTTPException
from sqlalchemy.orm import Session
import os
import jwt
from dotenv import load_dotenv
from routes.invite import invite_router
from db import get_db
from routes.auth import decode_jwt_token

@invite_router.post("/test-email")
async def test_email(
    db: Session = Depends(get_db),
    current_user: dict = Depends(decode_jwt_token)
):
    try:
        # Example for user-configured email
        send_invite_email(
            db=db,
            sender_email="your_test@email.com",  # Use a real email
            sender_password="your_app_password",  # Use an app-specific password
            receiver_email="recipient@example.com",
            project_id=1,  # Must exist in DB
            invite_link="https://yourdomain.com/invite?token=test123"
        )
        return {"status": "Email sent successfully"}
    except Exception as e:
        raise HTTPException(500, detail=str(e))