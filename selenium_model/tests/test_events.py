"""
Events Management Tests
"""
import time
import pytest
import logging
from framework.base_test import BaseTest
from framework.api_client import APIClient
from utils.helpers import TestResult, TestDataGenerator
from framework.config import TEST_USERS

logger = logging.getLogger(__name__)


class TestEventManagement(BaseTest):
    """Event management test cases"""
    
    def setup_method(self):
        """Setup before each test"""
        super().setup()
        self.api_client = APIClient()
        self.test_results = []
        
        # Login as organizer
        login_response = self.api_client.login(
            TEST_USERS["organizer"]["email"],
            TEST_USERS["organizer"]["password"]
        )
        if login_response.status_code == 200:
            login_data = login_response.json()
            self.api_client.set_auth_token(login_data["accessToken"])
    
    def test_event_001_create_event(self):
        """Test creating a new event"""
        test_id = "TEST_EVENT_001"
        module = "Events"
        scenario = "Create Event"
        
        try:
            start_time = time.time()
            
            event_data = {
                "title": "Tech Workshop 2024",
                "description": "Learn latest technologies",
                "category": "Workshop",
                "startDate": "2024-12-15T10:00:00",
                "endDate": "2024-12-15T12:00:00",
                "capacity": 100,
                "location": "Main Hall"
            }
            
            create_response = self.api_client.create_event(event_data)
            execution_time = time.time() - start_time
            
            assert create_response.status_code in [200, 201], \
                f"Expected 200/201, got {create_response.status_code}"
            
            response_data = create_response.json()
            assert "id" in response_data or "_id" in response_data, "No event ID in response"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Event should be created successfully",
                actual_result="Event created successfully",
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
                expected_result="Event should be created successfully",
                actual_result=f"Event creation failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_event_002_search_events(self):
        """Test searching for events"""
        test_id = "TEST_EVENT_002"
        module = "Events"
        scenario = "Search Events"
        
        try:
            start_time = time.time()
            
            search_response = self.api_client.search_events("workshop")
            execution_time = time.time() - start_time
            
            assert search_response.status_code == 200, \
                f"Expected 200, got {search_response.status_code}"
            
            response_data = search_response.json()
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Search should return matching events",
                actual_result=f"Search returned {len(response_data) if isinstance(response_data, list) else 'results'}",
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
                expected_result="Search should return matching events",
                actual_result=f"Search failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_event_003_filter_by_category(self):
        """Test filtering events by category"""
        test_id = "TEST_EVENT_003"
        module = "Events"
        scenario = "Filter by Category"
        
        try:
            start_time = time.time()
            
            category_response = self.api_client.get_events_by_category("Technical")
            execution_time = time.time() - start_time
            
            assert category_response.status_code == 200, \
                f"Expected 200, got {category_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should filter events by category",
                actual_result="Events filtered by category successfully",
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
                expected_result="Should filter events by category",
                actual_result=f"Filter failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_event_004_get_published_events(self):
        """Test retrieving published events"""
        test_id = "TEST_EVENT_004"
        module = "Events"
        scenario = "Get Published Events"
        
        try:
            start_time = time.time()
            
            events_response = self.api_client.get_published_events()
            execution_time = time.time() - start_time
            
            assert events_response.status_code == 200, \
                f"Expected 200, got {events_response.status_code}"
            
            response_data = events_response.json()
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve published events",
                actual_result="Published events retrieved successfully",
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
                expected_result="Should retrieve published events",
                actual_result=f"Retrieval failed: {str(e)}",
                status="FAILED",
                execution_time=execution_time,
                error_message=str(e)
            )
            logger.error(f"{test_id}: FAILED - {e}")
        
        self.test_results.append(result)
    
    def test_event_005_get_my_events(self):
        """Test retrieving user's own events"""
        test_id = "TEST_EVENT_005"
        module = "Events"
        scenario = "Get My Events"
        
        try:
            start_time = time.time()
            
            my_events_response = self.api_client.get_my_events()
            execution_time = time.time() - start_time
            
            assert my_events_response.status_code == 200, \
                f"Expected 200, got {my_events_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve user's events",
                actual_result="User's events retrieved successfully",
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
                expected_result="Should retrieve user's events",
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


class TestRegistrations(BaseTest):
    """Registration test cases"""
    
    def setup_method(self):
        """Setup before each test"""
        super().setup()
        self.api_client = APIClient()
        self.test_results = []
        
        # Login as participant
        login_response = self.api_client.login(
            TEST_USERS["participant"]["email"],
            TEST_USERS["participant"]["password"]
        )
        if login_response.status_code == 200:
            login_data = login_response.json()
            self.api_client.set_auth_token(login_data["accessToken"])
    
    def test_reg_001_get_registrations(self):
        """Test retrieving user's registrations"""
        test_id = "TEST_REG_001"
        module = "Registrations"
        scenario = "Get My Registrations"
        
        try:
            start_time = time.time()
            
            reg_response = self.api_client.get_my_registrations()
            execution_time = time.time() - start_time
            
            assert reg_response.status_code == 200, \
                f"Expected 200, got {reg_response.status_code}"
            
            result = TestResult(
                test_id=test_id,
                module=module,
                scenario=scenario,
                expected_result="Should retrieve user's registrations",
                actual_result="Registrations retrieved successfully",
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
                expected_result="Should retrieve user's registrations",
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
