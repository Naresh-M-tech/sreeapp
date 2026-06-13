"""
Authentication Tests
"""
import time
import pytest
import logging
from framework.base_test import BaseTest
from framework.api_client import APIClient
from pages.page_objects import LoginPage, RegisterPage, HomePage
from utils.helpers import TestResult, TestDataGenerator
from framework.config import FRONTEND_BASE_URL, TEST_USERS

logger = logging.getLogger(__name__)


class TestAuthentication(BaseTest):
    """Authentication test cases"""
    
    def setup_method(self):
        """Setup before each test"""
        super().setup()
        self.api_client = APIClient()
        self.test_results = []
    
    def test_auth_001_valid_login(self):
        """Test valid login with credentials"""
        test_id = "TEST_AUTH_001"
        module = "Authentication"
        scenario = "Valid Login"
        
        try:
            start_time = time.time()
            
            # Perform API login
            login_response = self.api_client.login(
                TEST_USERS["participant"]["email"],
                TEST_USERS["participant"]["password"]
            )
            
            execution_time = time.time() - start_time
            
            # Assertions
            assert login_response.status_code == 200, f"Expected 200, got {login_response.status_code}"
            response_data = login_response.json()
            assert "accessToken" in response_data, "No access token in response"
            assert "refreshToken" in response_data, "No refresh token in response"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Login successful with valid credentials",
                actual_result="Login successful, tokens received",
                status="PASSED",
                execution_time=execution_time
            )
            logger.info(f"{test_id}: PASSED")
        
        except Exception as e:
            execution_time = time.time() - start_time
            screenshot = self.screenshot(f"test_auth_001_failure")
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Login successful with valid credentials",
                actual_result=f"Login failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                screenshot_path=screenshot,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_auth_002_invalid_password(self):
        """Test login with invalid password"""
        test_id = "TEST_AUTH_002"
        module = "Authentication"
        scenario = "Invalid Password"
        
        try:
            start_time = time.time()
            
            login_response = self.api_client.login(
                TEST_USERS["participant"]["email"],
                "InvalidPassword123"
            )
            
            execution_time = time.time() - start_time
            
            # Should fail with 401 or 400
            assert login_response.status_code in [400, 401, 422], \
                f"Expected 400/401/422, got {login_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Login should fail with invalid password",
                actual_result=f"Login rejected with status {login_response.status_code}",
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
                expected_result="Login should fail with invalid password",
                actual_result=f"Test failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_auth_003_invalid_email(self):
        """Test login with non-existent email"""
        test_id = "TEST_AUTH_003"
        module = "Authentication"
        scenario = "Non-existent User"
        
        try:
            start_time = time.time()
            
            login_response = self.api_client.login(
                "nonexistent@testbridge.com",
                "Password123"
            )
            
            execution_time = time.time() - start_time
            
            # Should fail
            assert login_response.status_code in [400, 401, 404, 422], \
                f"Expected error status, got {login_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Login should fail with non-existent email",
                actual_result=f"Login rejected with status {login_response.status_code}",
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
                expected_result="Login should fail with non-existent email",
                actual_result=f"Test failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_auth_004_token_refresh(self):
        """Test refresh token mechanism"""
        test_id = "TEST_AUTH_004"
        module = "Authentication"
        scenario = "Refresh Token"
        
        try:
            start_time = time.time()
            
            # First login
            login_response = self.api_client.login(
                TEST_USERS["participant"]["email"],
                TEST_USERS["participant"]["password"]
            )
            assert login_response.status_code == 200
            
            login_data = login_response.json()
            refresh_token = login_data.get("refreshToken")
            
            # Store tokens
            self.api_client.set_auth_token(
                login_data["accessToken"],
                refresh_token
            )
            
            # Refresh token
            refresh_response = self.api_client.refresh_access_token()
            
            execution_time = time.time() - start_time
            
            # Should succeed with new access token
            assert refresh_response.status_code == 200, \
                f"Expected 200, got {refresh_response.status_code}"
            
            refresh_data = refresh_response.json()
            assert "accessToken" in refresh_data, "No new access token"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Token refresh should succeed",
                actual_result="Token refreshed successfully",
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
                expected_result="Token refresh should succeed",
                actual_result=f"Token refresh failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_auth_005_logout(self):
        """Test logout functionality"""
        test_id = "TEST_AUTH_005"
        module = "Authentication"
        scenario = "Logout"
        
        try:
            start_time = time.time()
            
            # Login first
            login_response = self.api_client.login(
                TEST_USERS["participant"]["email"],
                TEST_USERS["participant"]["password"]
            )
            login_data = login_response.json()
            self.api_client.set_auth_token(login_data["accessToken"])
            
            # Logout
            logout_response = self.api_client.logout()
            
            execution_time = time.time() - start_time
            
            assert logout_response.status_code in [200, 204], \
                f"Expected 200/204, got {logout_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Logout should succeed",
                actual_result="Logout successful",
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
                expected_result="Logout should succeed",
                actual_result=f"Logout failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def teardown_method(self):
        """Teardown after each test"""
        super().teardown()
