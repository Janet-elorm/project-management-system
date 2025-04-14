from cryptography.fernet import Fernet
import os
from dotenv import load_dotenv

load_dotenv()

# Generate a key once (run Fernet.generate_key()) and store in .env
KEY = os.getenv("ENCRYPTION_KEY")
cipher = Fernet(KEY.encode())

def encrypt_password(password: str) -> str:
    return cipher.encrypt(password.encode()).decode()

def decrypt_password(encrypted: str) -> str:
    return cipher.decrypt(encrypted.encode()).decode()