# main.py
import os
import time
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, Depends
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, OperationFailure
from prometheus_client import (
    Counter,
    Histogram,
    Gauge,
    generate_latest,
    CONTENT_TYPE_LATEST,
)
from fastapi.responses import Response

# Prometheus metrics
REQUEST_COUNT = Counter(
    "http_requests_total", "Total HTTP requests", ["method", "endpoint", "status"]
)
REQUEST_LATENCY = Histogram("http_request_duration_seconds", "HTTP request latency")
ACTIVE_CONNECTIONS = Gauge("active_connections", "Number of active connections")
MONGODB_CONNECTION_STATUS = Gauge(
    "mongodb_connection_status",
    "MongoDB connection status (1=connected, 0=disconnected)",
)

# Get MongoDB configuration from environment variables
MONGO_HOST = os.environ.get("MONGO_HOST", "mongo-service")
MONGO_PORT = int(os.environ.get("MONGO_PORT", 27017))
MONGO_USER = os.environ.get("MONGO_USER")
MONGO_PASS = os.environ.get("MONGO_PASS")
MONGO_DB = os.environ.get("MONGO_DB", "testdb")

# Build the MongoDB connection URL
# Temporarily disable authentication for load testing
mongo_url = f"mongodb://{MONGO_HOST}:{MONGO_PORT}/{MONGO_DB}"
print(f"Connecting to MongoDB without authentication: {mongo_url}")

db_connection = {}
startup_time = time.time()


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Connect to MongoDB
    print("Attempting to connect to MongoDB...")
    try:
        client = MongoClient(mongo_url, serverSelectionTimeoutMS=5000)
        client.admin.command("ping")
        db_connection["client"] = client
        db_connection["db"] = client[MONGO_DB]
        MONGODB_CONNECTION_STATUS.set(1)
        print(f"Successfully connected to MongoDB at {MONGO_HOST}:{MONGO_PORT}")
        print(f"Using database: {MONGO_DB}")
    except (ConnectionFailure, OperationFailure) as e:
        print(f"Failed to connect to MongoDB: {e}")
        db_connection["client"] = None
        db_connection["db"] = None
        MONGODB_CONNECTION_STATUS.set(0)

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
    REQUEST_COUNT.labels(method="GET", endpoint="/", status="200").inc()
    return {
        "message": "FastAPI is working!",
        "mongo_connected": db_connection.get("client") is not None,
        "mongo_host": MONGO_HOST,
        "mongo_port": MONGO_PORT,
        "mongo_db": MONGO_DB,
        "config_source": "ConfigMap and Secret (Phase 2)",
        "uptime_seconds": int(time.time() - startup_time),
    }


@app.get("/health")
def health_check():
    """Basic health check endpoint for Kubernetes probes"""
    if db_connection.get("client") is None:
        REQUEST_COUNT.labels(method="GET", endpoint="/health", status="503").inc()
        raise HTTPException(status_code=503, detail="MongoDB connection failed")

    REQUEST_COUNT.labels(method="GET", endpoint="/health", status="200").inc()
    return {"status": "healthy", "mongo_connected": True}


@app.get("/ready")
def readiness_check():
    """Readiness probe endpoint - checks if app is ready to serve traffic"""
    try:
        # Check MongoDB connection
        if db_connection.get("client") is None:
            REQUEST_COUNT.labels(method="GET", endpoint="/ready", status="503").inc()
            return {"status": "not_ready", "reason": "MongoDB not connected"}

        # Test MongoDB ping
        db_connection["client"].admin.command("ping")

        REQUEST_COUNT.labels(method="GET", endpoint="/ready", status="200").inc()
        return {
            "status": "ready",
            "mongo_connected": True,
            "uptime_seconds": int(time.time() - startup_time),
        }
    except Exception as e:
        REQUEST_COUNT.labels(method="GET", endpoint="/ready", status="503").inc()
        return {"status": "not_ready", "reason": f"Database error: {str(e)}"}


@app.get("/live")
def liveness_check():
    """Liveness probe endpoint - checks if app is alive and responsive"""
    try:
        # Basic application health check
        REQUEST_COUNT.labels(method="GET", endpoint="/live", status="200").inc()
        return {
            "status": "alive",
            "uptime_seconds": int(time.time() - startup_time),
            "timestamp": time.time(),
        }
    except Exception as e:
        REQUEST_COUNT.labels(method="GET", endpoint="/live", status="500").inc()
        raise HTTPException(status_code=500, detail=f"Application error: {str(e)}")


@app.get("/metrics")
def get_metrics():
    """Prometheus metrics endpoint"""
    REQUEST_COUNT.labels(method="GET", endpoint="/metrics", status="200").inc()
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


@app.get("/metrics-basic")
def get_metrics_basic():
    """Basic metrics endpoint for monitoring"""
    REQUEST_COUNT.labels(method="GET", endpoint="/metrics-basic", status="200").inc()
    return {
        "uptime_seconds": int(time.time() - startup_time),
        "mongo_connected": db_connection.get("client") is not None,
        "memory_usage": "basic_metrics_available",
        "requests_served": "tracking_available",
    }


@app.post("/items/")
def create_item(name: str, description: str, db=Depends(get_db)):
    start_time = time.time()
    try:
        item = {"name": name, "description": description}
        result = db.items.insert_one(item)
        REQUEST_COUNT.labels(method="POST", endpoint="/items", status="200").inc()
        REQUEST_LATENCY.observe(time.time() - start_time)
        return {"id": str(result.inserted_id), "name": name, "description": description}
    except Exception as e:
        REQUEST_COUNT.labels(method="POST", endpoint="/items", status="500").inc()
        REQUEST_LATENCY.observe(time.time() - start_time)
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/items/")
def get_items(db=Depends(get_db)):
    start_time = time.time()
    try:
        items = list(db.items.find({}, {"_id": 0}))
        REQUEST_COUNT.labels(method="GET", endpoint="/items", status="200").inc()
        REQUEST_LATENCY.observe(time.time() - start_time)
        return {"items": items}
    except Exception as e:
        REQUEST_COUNT.labels(method="GET", endpoint="/items", status="500").inc()
        REQUEST_LATENCY.observe(time.time() - start_time)
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/load-test")
def load_test_endpoint():
    """Endpoint for load testing - simulates CPU intensive work"""
    start_time = time.time()

    # Simulate CPU intensive work
    result = 0
    for i in range(1000000):
        result += i * i

    REQUEST_COUNT.labels(method="GET", endpoint="/load-test", status="200").inc()
    REQUEST_LATENCY.observe(time.time() - start_time)

    return {
        "message": "Load test completed",
        "result": result,
        "processing_time": time.time() - start_time,
    }
