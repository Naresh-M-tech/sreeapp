"""
Page Object Models for EventBridge Application
"""
import logging
from selenium.webdriver.common.by import By
from framework.base_test import BaseTest

logger = logging.getLogger(__name__)


class BasePage(BaseTest):
    """Base page object"""
    
    def __init__(self):
        super().__init__()
    
    def verify_page_loaded(self, title_text: str = None) -> bool:
        """Verify page loaded"""
        try:
            if title_text:
                return title_text.lower() in self.driver.title.lower()
            return self.driver.title is not None
        except:
            return False


class LoginPage(BasePage):
    """Login Page Object"""
    
    # Locators
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[type='password']")
    LOGIN_BUTTON = (By.XPATH, "//button[contains(text(), 'Login')]")
    SIGNUP_LINK = (By.XPATH, "//a[contains(text(), 'Sign Up')]")
    FORGOT_PASSWORD_LINK = (By.XPATH, "//a[contains(text(), 'Forgot')]")
    ERROR_MESSAGE = (By.CSS_SELECTOR, ".error-message")
    
    def login(self, email: str, password: str):
        """Perform login"""
        logger.info(f"Logging in with email: {email}")
        self.wait_and_send_keys(self.EMAIL_INPUT, email)
        self.wait_and_send_keys(self.PASSWORD_INPUT, password)
        self.wait_and_click(self.LOGIN_BUTTON)
    
    def get_error_message(self) -> str:
        """Get error message"""
        if self.is_element_present(self.ERROR_MESSAGE):
            return self.get_element_text(self.ERROR_MESSAGE)
        return ""
    
    def click_signup(self):
        """Click signup link"""
        self.wait_and_click(self.SIGNUP_LINK)
    
    def click_forgot_password(self):
        """Click forgot password link"""
        self.wait_and_click(self.FORGOT_PASSWORD_LINK)


class RegisterPage(BasePage):
    """Register Page Object"""
    
    # Locators
    NAME_INPUT = (By.XPATH, "//input[@placeholder*='Name']")
    EMAIL_INPUT = (By.CSS_SELECTOR, "input[type='email']")
    PASSWORD_INPUT = (By.CSS_SELECTOR, "input[type='password']")
    CONFIRM_PASSWORD_INPUT = (By.XPATH, "//input[@placeholder*='Confirm']")
    ROLE_DROPDOWN = (By.CSS_SELECTOR, "select[name='role']")
    REGISTER_BUTTON = (By.XPATH, "//button[contains(text(), 'Register')]")
    SUCCESS_MESSAGE = (By.CSS_SELECTOR, ".success-message")
    ERROR_MESSAGE = (By.CSS_SELECTOR, ".error-message")
    
    def register(self, name: str, email: str, password: str, role: str = "PARTICIPANT"):
        """Perform registration"""
        logger.info(f"Registering user: {email}")
        self.wait_and_send_keys(self.NAME_INPUT, name)
        self.wait_and_send_keys(self.EMAIL_INPUT, email)
        self.wait_and_send_keys(self.PASSWORD_INPUT, password)
        self.wait_and_send_keys(self.CONFIRM_PASSWORD_INPUT, password)
        
        # Select role
        role_dropdown = self.wait_and_find(self.ROLE_DROPDOWN)
        role_dropdown.select_by_value(role)
        
        self.wait_and_click(self.REGISTER_BUTTON)
    
    def get_success_message(self) -> str:
        """Get success message"""
        if self.is_element_present(self.SUCCESS_MESSAGE):
            return self.get_element_text(self.SUCCESS_MESSAGE)
        return ""
    
    def get_error_message(self) -> str:
        """Get error message"""
        if self.is_element_present(self.ERROR_MESSAGE):
            return self.get_element_text(self.ERROR_MESSAGE)
        return ""


class HomePage(BasePage):
    """Home/Dashboard Page Object"""
    
    # Locators
    WELCOME_TEXT = (By.XPATH, "//*[contains(text(), 'Welcome')]")
    SEARCH_INPUT = (By.CSS_SELECTOR, "input[placeholder*='Search']")
    CATEGORY_FILTER = (By.CSS_SELECTOR, "select[name='category']")
    EVENT_CARDS = (By.CSS_SELECTOR, "[class*='event-card']")
    LOGOUT_BUTTON = (By.XPATH, "//button[contains(text(), 'Logout')]")
    USER_PROFILE = (By.CSS_SELECTOR, "[class*='profile']")
    
    def search_events(self, query: str):
        """Search for events"""
        logger.info(f"Searching for events: {query}")
        self.wait_and_send_keys(self.SEARCH_INPUT, query)
    
    def filter_by_category(self, category: str):
        """Filter events by category"""
        logger.info(f"Filtering by category: {category}")
        category_dropdown = self.wait_and_find(self.CATEGORY_FILTER)
        category_dropdown.select_by_value(category)
    
    def get_event_count(self) -> int:
        """Get number of event cards displayed"""
        events = self.driver.find_elements(*self.EVENT_CARDS)
        return len(events)
    
    def click_event(self, event_index: int):
        """Click on event"""
        events = self.driver.find_elements(*self.EVENT_CARDS)
        if event_index < len(events):
            events[event_index].click()
    
    def logout(self):
        """Logout"""
        logger.info("Logging out")
        self.wait_and_click(self.LOGOUT_BUTTON)


class EventDetailsPage(BasePage):
    """Event Details Page Object"""
    
    # Locators
    EVENT_TITLE = (By.XPATH, "//h1")
    EVENT_DESCRIPTION = (By.CSS_SELECTOR, "[class*='description']")
    REGISTER_BUTTON = (By.XPATH, "//button[contains(text(), 'Register')]")
    REGISTERED_BADGE = (By.XPATH, "//*[contains(text(), 'Registered')]")
    TEAM_SECTION = (By.CSS_SELECTOR, "[class*='team']")
    CREATE_TEAM_BUTTON = (By.XPATH, "//button[contains(text(), 'Create Team')]")
    JOIN_TEAM_BUTTON = (By.XPATH, "//button[contains(text(), 'Join')]")
    
    def get_event_title(self) -> str:
        """Get event title"""
        return self.get_element_text(self.EVENT_TITLE)
    
    def register_for_event(self):
        """Register for event"""
        logger.info("Registering for event")
        self.wait_and_click(self.REGISTER_BUTTON)
    
    def is_already_registered(self) -> bool:
        """Check if already registered"""
        return self.is_element_present(self.REGISTERED_BADGE)
    
    def create_team(self):
        """Create team"""
        self.wait_and_click(self.CREATE_TEAM_BUTTON)


class CreateEventPage(BasePage):
    """Create Event Page Object (for Organizers)"""
    
    # Locators
    TITLE_INPUT = (By.XPATH, "//input[@placeholder*='Title']")
    DESCRIPTION_INPUT = (By.XPATH, "//textarea[@placeholder*='Description']")
    CATEGORY_DROPDOWN = (By.CSS_SELECTOR, "select[name='category']")
    START_DATE_INPUT = (By.XPATH, "//input[@type='datetime-local']")
    CAPACITY_INPUT = (By.XPATH, "//input[@placeholder*='Capacity']")
    CREATE_BUTTON = (By.XPATH, "//button[contains(text(), 'Create')]")
    SUCCESS_MESSAGE = (By.CSS_SELECTOR, ".success-message")
    
    def fill_event_form(self, event_data: dict):
        """Fill event creation form"""
        logger.info(f"Filling event form with data: {event_data}")
        
        self.wait_and_send_keys(self.TITLE_INPUT, event_data['title'])
        self.wait_and_send_keys(self.DESCRIPTION_INPUT, event_data['description'])
        
        category_dropdown = self.wait_and_find(self.CATEGORY_DROPDOWN)
        category_dropdown.select_by_value(event_data['category'])
        
        self.wait_and_send_keys(self.START_DATE_INPUT, event_data['startDate'])
        self.wait_and_send_keys(self.CAPACITY_INPUT, str(event_data['capacity']))
    
    def submit_event(self):
        """Submit event form"""
        self.wait_and_click(self.CREATE_BUTTON)
    
    def get_success_message(self) -> str:
        """Get success message"""
        if self.is_element_present(self.SUCCESS_MESSAGE):
            return self.get_element_text(self.SUCCESS_MESSAGE)
        return ""


class ChatPage(BasePage):
    """Chat Page Object"""
    
    # Locators
    CHAT_INPUT = (By.CSS_SELECTOR, "input[placeholder*='message']")
    SEND_BUTTON = (By.XPATH, "//button[contains(text(), 'Send')]")
    CHAT_MESSAGES = (By.CSS_SELECTOR, "[class*='message']")
    CHAT_ROOMS = (By.CSS_SELECTOR, "[class*='room']")
    
    def send_message(self, message: str):
        """Send chat message"""
        logger.info(f"Sending message: {message}")
        self.wait_and_send_keys(self.CHAT_INPUT, message)
        self.wait_and_click(self.SEND_BUTTON)
    
    def get_message_count(self) -> int:
        """Get number of messages"""
        messages = self.driver.find_elements(*self.CHAT_MESSAGES)
        return len(messages)
    
    def get_last_message_text(self) -> str:
        """Get last message text"""
        messages = self.driver.find_elements(*self.CHAT_MESSAGES)
        if messages:
            return messages[-1].text
        return ""


class NotificationsPage(BasePage):
    """Notifications Page Object"""
    
    # Locators
    NOTIFICATION_ITEMS = (By.CSS_SELECTOR, "[class*='notification']")
    NOTIFICATION_BADGE = (By.CSS_SELECTOR, "[class*='badge']")
    MARK_READ_BUTTON = (By.XPATH, "//button[contains(text(), 'Mark as Read')]")
    
    def get_notification_count(self) -> int:
        """Get notification count"""
        items = self.driver.find_elements(*self.NOTIFICATION_ITEMS)
        return len(items)
    
    def get_unread_badge_count(self) -> int:
        """Get unread count from badge"""
        try:
            badge_text = self.get_element_text(self.NOTIFICATION_BADGE)
            return int(badge_text)
        except:
            return 0


class AdminDashboardPage(BasePage):
    """Admin Dashboard Page Object"""
    
    # Locators
    USERS_TAB = (By.XPATH, "//a[contains(text(), 'Users')]")
    EVENTS_TAB = (By.XPATH, "//a[contains(text(), 'Events')]")
    ANALYTICS_TAB = (By.XPATH, "//a[contains(text(), 'Analytics')]")
    PENDING_EVENTS = (By.CSS_SELECTOR, "[class*='pending-event']")
    APPROVE_BUTTON = (By.XPATH, "//button[contains(text(), 'Approve')]")
    REJECT_BUTTON = (By.XPATH, "//button[contains(text(), 'Reject')]")
    USER_LIST = (By.CSS_SELECTOR, "[class*='user-row']")
    
    def click_users_tab(self):
        """Click users tab"""
        self.wait_and_click(self.USERS_TAB)
    
    def click_events_tab(self):
        """Click events tab"""
        self.wait_and_click(self.EVENTS_TAB)
    
    def click_analytics_tab(self):
        """Click analytics tab"""
        self.wait_and_click(self.ANALYTICS_TAB)
    
    def get_pending_events_count(self) -> int:
        """Get pending events count"""
        events = self.driver.find_elements(*self.PENDING_EVENTS)
        return len(events)
    
    def approve_first_event(self):
        """Approve first pending event"""
        self.wait_and_click(self.APPROVE_BUTTON)
    
    def get_user_count(self) -> int:
        """Get user count"""
        users = self.driver.find_elements(*self.USER_LIST)
        return len(users)


class OdManagementPage(BasePage):
    """OD Management Page Object"""
    
    # Locators
    CREATE_OD_BUTTON = (By.XPATH, "//button[contains(text(), 'Create OD')]")
    OD_FORM_TITLE = (By.XPATH, "//input[@placeholder*='Title']")
    OD_FORM_REASON = (By.XPATH, "//textarea[@placeholder*='Reason']")
    OD_FORM_DATES = (By.CSS_SELECTOR, "input[type='date']")
    SUBMIT_OD_BUTTON = (By.XPATH, "//button[contains(text(), 'Submit')]")
    OD_LIST = (By.CSS_SELECTOR, "[class*='od-item']")
    APPROVE_OD_BUTTON = (By.XPATH, "//button[contains(text(), 'Approve')]")
    REJECT_OD_BUTTON = (By.XPATH, "//button[contains(text(), 'Reject')]")
    
    def create_od_request(self, title: str, reason: str, start_date: str, end_date: str):
        """Create OD request"""
        logger.info("Creating OD request")
        self.wait_and_click(self.CREATE_OD_BUTTON)
        self.wait_and_send_keys(self.OD_FORM_TITLE, title)
        self.wait_and_send_keys(self.OD_FORM_REASON, reason)
    
    def get_od_count(self) -> int:
        """Get OD requests count"""
        od_items = self.driver.find_elements(*self.OD_LIST)
        return len(od_items)
    
    def approve_od(self):
        """Approve OD"""
        self.wait_and_click(self.APPROVE_OD_BUTTON)
    
    def reject_od(self):
        """Reject OD"""
        self.wait_and_click(self.REJECT_OD_BUTTON)
