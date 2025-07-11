from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

import os

DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "rootpassword")
DB_HOST = os.getenv("DB_HOST", "mariadb")
DB_NAME = os.getenv("DB_NAME", "productdb")

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

engine = create_engine(DATABASE_URL, echo=True, future=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
