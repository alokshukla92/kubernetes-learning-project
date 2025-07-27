# main.py
import os
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure

# Get MongoDB configuration from environment variables
MONGO_HOST = os.environ.get("MONGO_HOST", "mongo-service")
MONGO_PORT = int(os.environ.get("MONGO_PORT", 27017))
MONGO_USER = os.environ.get("MONGO_USER")
MONGO_PASS = os.environ.get("MONGO_PASS")
MONGO_DB = os.environ.get("MONGO_DB", "testdb")

# Build the MongoDB connection URL
if MONGO_USER and MONGO_PASS:
    # Use authentication if user/password are provided from secrets
    mongo_url = f"mongodb://{MONGO_USER}:{MONGO_PASS}@{MONGO_HOST}:{MONGO_PORT}/{MONGO_DB}?authSource=admin"
    print(
        f"Connecting to MongoDB with authentication: mongodb://<user>:<password>@{MONGO_HOST}:{MONGO_PORT}"
    )
else:
    # Fallback for connecting without authentication
    mongo_url = f"mongodb://{MONGO_HOST}:{MONGO_PORT}/{MONGO_DB}"
    print(f"Connecting to MongoDB without authentication: {mongo_url}")

db_connection = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Connect to MongoDB
    print("Attempting to connect to MongoDB...")
    try:
        client = MongoClient(mongo_url, serverSelectionTimeoutMS=5000)
        client.admin.command("ping")
        db_connection["client"] = client
        db_connection["db"] = client[MONGO_DB]
        print(f"Successfully connected to MongoDB at {MONGO_HOST}:{MONGO_PORT}")
        print(f"Using database: {MONGO_DB}")
    except (ConnectionFailure, OperationFailure) as e:
        print(f"Failed to connect to MongoDB: {e}")
        db_connection["client"] = None
        db_connection["db"] = None

    yield

    # Shutdown: Close the connection
    if db_connection.get("client"):
        print("Closing MongoDB connection.")
        db_connection["client"].close()


app = FastAPI(lifespan=lifespan)


def get_db():
    if db_connection.get("db") is None:
        raise HTTPException(status_code=503, detail="MongoDB not available")
    return db_connection["db"]


@app.get("/")
def read_root():
    return {
        "message": "FastAPI is working!",
        "mongo_connected": db_connection.get("client") is not None,
        "mongo_host": MONGO_HOST,
        "mongo_port": MONGO_PORT,
        "mongo_db": MONGO_DB,
        "config_source": "ConfigMap and Secret (Phase 2)",
    }


@app.get("/health")
def health_check():
    if db_connection.get("client") is None:
        raise HTTPException(status_code=503, detail="MongoDB connection failed")
    return {"status": "healthy", "mongo_connected": True}


@app.post("/items/")
def create_item(name: str, description: str, db=Depends(get_db)):
    item = {"name": name, "description": description}
    result = db.items.insert_one(item)
    return {"id": str(result.inserted_id), "name": name, "description": description}


@app.get("/items/")
def get_items(db=Depends(get_db)):
    items = list(db.items.find({}, {"_id": 0}))
    return {"items": items}
