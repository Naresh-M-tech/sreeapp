"""
Configuration for Selenium Test Framework
"""
import os
from pathlib import Path
from enum import Enum

# Project Paths
PROJECT_ROOT = Path(__file__).parent.parent.parent
SELENIUM_MODEL_DIR = PROJECT_ROOT / 'selenium_model'
TESTS_DIR = SELENIUM_MODEL_DIR / 'tests'
FRAMEWORK_DIR = SELENIUM_MODEL_DIR / 'framework'
PAGES_DIR = SELENIUM_MODEL_DIR / 'pages'
UTILS_DIR = SELENIUM_MODEL_DIR / 'utils'
LOGS_DIR = SELENIUM_MODEL_DIR / 'logs'
SCREENSHOTS_DIR = SELENIUM_MODEL_DIR / 'screenshots'
EVIDENCE_DIR = SELENIUM_MODEL_DIR / 'evidence'
REPORTS_DIR = SELENIUM_MODEL_DIR / 'reports'

# Create directories if not exist
for directory in [LOGS_DIR, SCREENSHOTS_DIR, EVIDENCE_DIR, REPORTS_DIR]:
    directory.mkdir(parents=True, exist_ok=True)

# Test Configuration
class Environment(Enum):
    LOCAL = "local"
    STAGING = "staging"
    PRODUCTION = "production"

class Browser(Enum):
    CHROME = "chrome"
    FIREFOX = "firefox"
    EDGE = "edge"

# Backend Configuration
BACKEND_BASE_URL = os.getenv("BACKEND_URL", "http://localhost:8080/api")
FRONTEND_BASE_URL = os.getenv("FRONTEND_URL", "http://localhost:3000")

# Test Users
TEST_USERS = {
    "admin": {
        "email": "admin@eventbridge.com",
        "password": "Admin@123456",
        "role": "ADMIN"
    },
    "organizer": {
        "email": "organizer@eventbridge.com",
        "password": "Organizer@123456",
        "role": "ORGANIZER"
    },
    "faculty": {
        "email": "faculty@eventbridge.com",
        "password": "Faculty@123456",
        "role": "FACULTY"
    },
    "participant": {
        "email": "participant@eventbridge.com",
        "password": "Participant@123456",
        "role": "PARTICIPANT"
    }
}

# Browser Configuration
DEFAULT_BROWSER = Browser.CHROME.value
HEADLESS_MODE = os.getenv("HEADLESS", "false").lower() == "true"
WAIT_TIME = 10  # seconds
IMPLICIT_WAIT = 5  # seconds
EXPLICIT_WAIT = 10  # seconds

# Selenium Configuration
SELENIUM_HOST = os.getenv("SELENIUM_HOST", "localhost")
SELENIUM_PORT = int(os.getenv("SELENIUM_PORT", "4444"))
REMOTE_GRID_URL = f"http://{SELENIUM_HOST}:{SELENIUM_PORT}"

# Logging Configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# Test Categories
class TestCategory(Enum):
    SMOKE = "smoke"
    REGRESSION = "regression"
    FUNCTIONAL = "functional"
    API = "api"
    UI = "ui"
    ACCESSIBILITY = "accessibility"
    PERFORMANCE = "performance"
    SECURITY = "security"
    E2E = "e2e"

# Report Configuration
REPORT_ENABLED = True
SCREENSHOT_ON_FAILURE = True
SCREENSHOT_ON_SUCCESS = False
KEEP_LOGS = True

# Timeout Configuration (in seconds)
PAGE_LOAD_TIMEOUT = 20
ELEMENT_WAIT_TIMEOUT = 15
ALERT_WAIT_TIMEOUT = 5
NOTIFICATION_WAIT_TIMEOUT = 10

# API Configuration
API_TIMEOUT = 30
API_RETRY_ATTEMPTS = 3
API_RETRY_DELAY = 1

# Email Configuration for Test Data
TEST_EMAIL_DOMAIN = "@testbridge.local"
GENERATE_UNIQUE_EMAILS = True

# Features to Test
FEATURES_TO_TEST = {
    "authentication": True,
    "events": True,
    "registration": True,
    "teams": True,
    "chat": True,
    "od_management": True,
    "analytics": True,
    "notifications": True,
    "user_management": True,
    "accessibility": True,
    "api_validation": True
}
