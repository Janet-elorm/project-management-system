import os
import pymysql
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

# Enable PyMySQL as MySQLdb
pymysql.install_as_MySQLdb()

# Escape special characters in the password: U$E& → U%24E%26
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "mysql+pymysql://user:capstone123@db:3306/capstone_project"  # KEEP this as is, container uses 3306
)

# Create SQLAlchemy engine
engine = create_engine(DATABASE_URL, pool_pre_ping=True)

# Create a configured session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()

# Dependency to get a DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
