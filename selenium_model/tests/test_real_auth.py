import pytest
import requests

BASE_URL = "http://localhost:8085/api"

def test_admin_login():
    response = requests.post(f"{BASE_URL}/auth/login", json={"email": "admin@eventbridge.com", "password": "Admin@123"})
    assert response.status_code == 200
    assert "token" in response.text

def test_organizer_login():
    response = requests.post(f"{BASE_URL}/auth/login", json={"email": "organizer@eventbridge.com", "password": "Org@123"})
    assert response.status_code == 200
    assert "token" in response.text

def test_faculty_login():
    response = requests.post(f"{BASE_URL}/auth/login", json={"email": "faculty@eventbridge.com", "password": "Faculty@123"})
    assert response.status_code == 200
    assert "token" in response.text

def test_invalid_password_rejection():
    response = requests.post(f"{BASE_URL}/auth/login", json={"email": "admin@eventbridge.com", "password": "WrongPassword"})
    assert response.status_code in [400, 401, 403]
