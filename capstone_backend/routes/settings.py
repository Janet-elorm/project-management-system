@auth_router.post("/email/setup")
async def setup_email(
    settings: schemas.EmailSettingsCreate,  # You'll need to create this schema
    db: Session = Depends(get_db),
    current_user: dict = Depends(decode_jwt_token)
):
    # Encrypt the password before storing
    encrypted = encrypt_password(settings.password)
    
    db_settings = models.UserEmailSettings(
        user_id=current_user["user_id"],
        email=settings.email,
        smtp_server=settings.smtp_server,
        smtp_port=settings.smtp_port,
        encrypted_password=encrypted
    )
    
    db.add(db_settings)
    db.commit()
    return {"message": "Email configured successfully"}