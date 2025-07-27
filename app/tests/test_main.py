import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


def test_read_root():
    """Test the root endpoint"""
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert data["message"] == "FastAPI is working!"


def test_health_endpoint():
    """Test the health endpoint"""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert data["status"] == "healthy"


def test_ready_endpoint():
    """Test the readiness endpoint"""
    response = client.get("/ready")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert data["status"] == "ready"


def test_live_endpoint():
    """Test the liveness endpoint"""
    response = client.get("/live")
    assert response.status_code == 200
    data = response.json()
    assert "status" in data
    assert data["status"] == "alive"


def test_metrics_endpoint():
    """Test the metrics endpoint"""
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "http_requests_total" in response.text


def test_load_test_endpoint():
    """Test the load test endpoint"""
    response = client.get("/load-test")
    assert response.status_code == 200
    data = response.json()
    assert "message" in data
    assert "timestamp" in data
