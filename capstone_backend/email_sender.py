import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from sqlalchemy.orm import Session
import models

from dotenv import load_dotenv

load_dotenv()  # Load environment variables

def send_invite_email(db: Session, receiver_email: str, project_id: int, invite_link: str):
    # Get credentials from environment
    sender_email = os.getenv("SMTP_EMAIL")
    sender_password = os.getenv("SMTP_PASSWORD")
    
    if not sender_email or not sender_password:
        raise ValueError("SMTP credentials not configured")

# Define SMTP configurations for multiple providers
SMTP_CONFIGS = {
    "gmail.com": {"server": "smtp.gmail.com", "port": 587},
    "outlook.com": {"server": "smtp.office365.com", "port": 587},
    "hotmail.com": {"server": "smtp.office365.com", "port": 587},
    "yahoo.com": {"server": "smtp.mail.yahoo.com", "port": 465},
    "zoho.com": {"server": "smtp.zoho.com", "port": 587},
    "icloud.com": {"server": "smtp.mail.me.com", "port": 587},
}

def get_smtp_config(email: str):
    """Determine the SMTP server based on the sender's email domain."""
    domain = email.split("@")[-1]  # Extract domain from email
    return SMTP_CONFIGS.get(domain, SMTP_CONFIGS["gmail.com"])  # Default to Gmail

def send_invite_email(db: Session, sender_email: str, sender_password: str, receiver_email: str, project_id: int, invite_link: str):
    # Fetch the project title from the database
    project = db.query(models.Project).filter(models.Project.project_id == project_id).first()
    
    if not project:
        print("Project not found!")
        return
    
    project_title = project.title  # Get the title of the project

    msg = MIMEMultipart()
    msg["From"] = sender_email
    msg["To"] = receiver_email
    msg["Subject"] = f"Invitation to Join {project_title} Project"

    body = f"""
    <html>
        <body>
            <h3>You have been invited to join the project: <strong>{project_title}</strong>!</h3>
            <p>Click the link below to accept the invitation:</p>
            <a href="{invite_link}">{invite_link}</a>
            <p>Best regards,</p>
            <p>{sender_email}</p>
        </body>
    </html>
    """
    msg.attach(MIMEText(body, "html"))

    # Get SMTP settings based on the sender's email provider
    smtp_config = get_smtp_config(sender_email)
    smtp_server = smtp_config["server"]
    smtp_port = smtp_config["port"]

    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(sender_email, sender_password)
        server.sendmail(sender_email, receiver_email, msg.as_string())
        server.quit()
        print(f"Invitation email sent successfully to {receiver_email}")
    except Exception as e:
        print(f"Failed to send email: {str(e)}")

        
        
        
