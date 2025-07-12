from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import os
import time
import sqlalchemy

DB_USER = os.getenv("DB_USER", "root")
DB_PASSWORD = os.getenv("DB_PASSWORD", "rootpassword")
DB_HOST = os.getenv("DB_HOST", "mariadb")
DB_NAME = os.getenv("DB_NAME", "paymentdb")

DATABASE_URL = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

engine = create_engine(DATABASE_URL, echo=True, future=True)

# --- Hier der Retry-Block ---
for i in range(20):  # z.B. 20 Versuche
    try:
        with engine.connect() as conn:
            print("DB connected!")
        break
    except sqlalchemy.exc.OperationalError:
        print("Waiting for MariaDB to be ready... (try %d/20)" % (i+1))
        time.sleep(3)
else:
    print("Could not connect to DB after many tries, exiting.")
    import sys; sys.exit(1)
# --- Ende Retry-Block ---

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
