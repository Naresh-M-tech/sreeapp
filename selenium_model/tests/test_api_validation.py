"""
API Validation Tests
"""
import time
import pytest
import logging
from framework.base_test import BaseTest
from framework.api_client import APIClient
from utils.helpers import TestResult, SecurityHelper
from framework.config import TEST_USERS, BACKEND_BASE_URL

logger = logging.getLogger(__name__)


class TestAPIValidation(BaseTest):
    """API validation and integration tests"""
    
    def setup_method(self):
        """Setup before each test"""
        super().setup()
        self.api_client = APIClient()
        self.test_results = []
    
    def test_api_001_auth_endpoint_accessibility(self):
        """Test authentication endpoint accessibility"""
        test_id = "TEST_API_001"
        module = "API Validation"
        scenario = "Auth Endpoint Accessibility"
        
        try:
            start_time = time.time()
            
            # Test auth endpoint
            response = self.api_client.post("/auth/login", json_data={
                "email": "test@test.com",
                "password": "test"
            })
            
            execution_time = time.time() - start_time
            
            # Just verify endpoint is accessible (even if auth fails)
            assert response.status_code in range(200, 500), \
                f"Endpoint not accessible: {response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Auth endpoint should be accessible",
                actual_result=f"Auth endpoint responded with {response.status_code}",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Auth endpoint should be accessible",
                actual_result=f"Endpoint not accessible: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_api_002_event_endpoint_accessibility(self):
        """Test event endpoint accessibility"""
        test_id = "TEST_API_002"
        module = "API Validation"
        scenario = "Event Endpoint Accessibility"
        
        try:
            start_time = time.time()
            
            response = self.api_client.get("/events/public/published")
            execution_time = time.time() - start_time
            
            assert response.status_code in range(200, 500), \
                f"Endpoint not accessible: {response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Event endpoint should be accessible",
                actual_result=f"Event endpoint responded with {response.status_code}",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Event endpoint should be accessible",
                actual_result=f"Endpoint not accessible: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_api_003_user_endpoint_authorization(self):
        """Test user endpoint requires authentication"""
        test_id = "TEST_API_003"
        module = "API Validation"
        scenario = "User Endpoint Authorization"
        
        try:
            start_time = time.time()
            
            # Try accessing protected endpoint without auth
            temp_client = APIClient()
            response = temp_client.get("/users/me")
            
            execution_time = time.time() - start_time
            
            # Should be unauthorized
            assert response.status_code in [401, 403], \
                f"Expected 401/403 for unauthorized, got {response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="User endpoint should require authentication",
                actual_result=f"Correctly rejected with {response.status_code}",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="User endpoint should require authentication",
                actual_result=f"Test failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_api_004_response_content_type(self):
        """Test API response content types"""
        test_id = "TEST_API_004"
        module = "API Validation"
        scenario = "Response Content Type"
        
        try:
            start_time = time.time()
            
            response = self.api_client.get("/events/public/published")
            
            execution_time = time.time() - start_time
            
            # Check content type
            content_type = response.headers.get('Content-Type', '')
            assert 'json' in content_type.lower() or response.status_code >= 400, \
                f"Expected JSON content type, got {content_type}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="API should return JSON content",
                actual_result=f"Correct content type: {content_type}",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="API should return JSON content",
                actual_result=f"Test failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_api_005_api_response_time(self):
        """Test API response time performance"""
        test_id = "TEST_API_005"
        module = "API Validation"
        scenario = "API Response Time"
        
        try:
            start_time = time.time()
            
            response = self.api_client.get("/events/public/published")
            
            execution_time = time.time() - start_time
            response_time = response.elapsed.total_seconds()
            
            # Should respond within 5 seconds
            assert response_time < 5.0, \
                f"API took too long: {response_time}s"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="API should respond within 5 seconds",
                actual_result=f"API responded in {response_time:.2f}s",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED - Response time: {response_time:.2f}s")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="API should respond within 5 seconds",
                actual_result=f"Test failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def teardown_method(self):
        """Teardown after each test"""
        super().teardown()


class TestNotifications(BaseTest):
    """Notification system tests"""
    
    def setup_method(self):
        """Setup before each test"""
        super().setup()
        self.api_client = APIClient()
        self.test_results = []
        
        # Login
        login_response = self.api_client.login(
            TEST_USERS["participant"]["email"],
            TEST_USERS["participant"]["password"]
        )
        if login_response.status_code == 200:
            login_data = login_response.json()
            self.api_client.set_auth_token(login_data["accessToken"])
    
    def test_notif_001_get_notifications(self):
        """Test retrieving notifications"""
        test_id = "TEST_NOTIF_001"
        module = "Notifications"
        scenario = "Get Notifications"
        
        try:
            start_time = time.time()
            
            notif_response = self.api_client.get_notifications()
            execution_time = time.time() - start_time
            
            assert notif_response.status_code == 200, \
                f"Expected 200, got {notif_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve notifications",
                actual_result="Notifications retrieved successfully",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve notifications",
                actual_result=f"Retrieval failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_notif_002_get_unread_count(self):
        """Test getting unread notification count"""
        test_id = "TEST_NOTIF_002"
        module = "Notifications"
        scenario = "Get Unread Count"
        
        try:
            start_time = time.time()
            
            count_response = self.api_client.get_unread_count()
            execution_time = time.time() - start_time
            
            assert count_response.status_code == 200, \
                f"Expected 200, got {count_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve unread count",
                actual_result="Unread count retrieved successfully",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve unread count",
                actual_result=f"Retrieval failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def teardown_method(self):
        """Teardown after each test"""
        super().teardown()
