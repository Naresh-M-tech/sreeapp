"""
Base Test Class for all Selenium Tests
"""
import logging
import pytest
from datetime import datetime
from pathlib import Path
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
from webdriver_manager.firefox import GeckoDriverManager
from selenium.webdriver.chrome.service import Service as ChromeService
from selenium.webdriver.firefox.service import Service as FirefoxService

from framework.config import (
    DEFAULT_BROWSER, HEADLESS_MODE, IMPLICIT_WAIT, EXPLICIT_WAIT,
    SCREENSHOTS_DIR, LOGS_DIR, LOG_LEVEL, SCREENSHOT_ON_FAILURE, 
    SCREENSHOT_ON_SUCCESS, FRONTEND_BASE_URL, BACKEND_BASE_URL
)

# Configure logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler(LOGS_DIR / f"test_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)


class BaseTest:
    """Base class for all Selenium tests"""
    
    driver = None
    wait = None
    
    @pytest.fixture(autouse=True)
    def setup_teardown(self):
        """Setup and teardown for each test"""
        self.setup()
        yield
        self.teardown()
    
    def setup(self):
        """Initialize WebDriver"""
        logger.info(f"Initializing WebDriver - Browser: {DEFAULT_BROWSER}")
        
        options = self.get_browser_options()
        
        if DEFAULT_BROWSER == "chrome":
            service = ChromeService(ChromeDriverManager().install())
            self.driver = webdriver.Chrome(service=service, options=options)
        elif DEFAULT_BROWSER == "firefox":
            service = FirefoxService(GeckoDriverManager().install())
            self.driver = webdriver.Firefox(service=service, options=options)
        else:
            raise ValueError(f"Unsupported browser: {DEFAULT_BROWSER}")
        
        self.driver.implicitly_wait(IMPLICIT_WAIT)
        self.wait = WebDriverWait(self.driver, EXPLICIT_WAIT)
        
        # Maximize window
        self.driver.maximize_window()
        
        logger.info("WebDriver initialized successfully")
    
    def get_browser_options(self):
        """Get browser options"""
        if DEFAULT_BROWSER == "chrome":
            options = webdriver.ChromeOptions()
            if HEADLESS_MODE:
                options.add_argument("--headless=new")
            options.add_argument("--no-sandbox")
            options.add_argument("--disable-dev-shm-usage")
            options.add_argument("--disable-gpu")
            options.add_argument("--disable-extensions")
            options.add_argument("--disable-popup-blocking")
            options.add_argument("--disable-notifications")
            options.add_argument("--start-maximized")
            options.add_argument("--window-size=1920,1080")
            # Ignore certificate errors
            options.add_argument("--ignore-certificate-errors")
            options.add_argument("--allow-insecure-localhost")
            return options
        elif DEFAULT_BROWSER == "firefox":
            options = webdriver.FirefoxOptions()
            if HEADLESS_MODE:
                options.add_argument("--headless")
            return options
    
    def teardown(self):
        """Close WebDriver"""
        if self.driver:
            try:
                self.driver.quit()
                logger.info("WebDriver closed successfully")
            except Exception as e:
                logger.error(f"Error closing WebDriver: {e}")
    
    def screenshot(self, name: str = None, on_success: bool = None):
        """Take screenshot"""
        if on_success is None:
            on_success = SCREENSHOT_ON_SUCCESS
        
        if on_success or (not on_success):
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"{name}_{timestamp}.png" if name else f"screenshot_{timestamp}.png"
            filepath = SCREENSHOTS_DIR / filename
            
            try:
                self.driver.save_screenshot(str(filepath))
                logger.info(f"Screenshot saved: {filepath}")
                return str(filepath)
            except Exception as e:
                logger.error(f"Error taking screenshot: {e}")
        
        return None
    
    def navigate_to(self, url: str):
        """Navigate to URL"""
        full_url = url if url.startswith("http") else f"{FRONTEND_BASE_URL}{url}"
        logger.info(f"Navigating to: {full_url}")
        self.driver.get(full_url)
    
    def wait_and_find(self, locator: tuple, timeout: int = None):
        """Wait for element and find it"""
        if timeout is None:
            timeout = EXPLICIT_WAIT
        wait = WebDriverWait(self.driver, timeout)
        return wait.until(EC.presence_of_element_located(locator))
    
    def wait_and_click(self, locator: tuple, timeout: int = None):
        """Wait for element and click it"""
        if timeout is None:
            timeout = EXPLICIT_WAIT
        wait = WebDriverWait(self.driver, timeout)
        element = wait.until(EC.element_to_be_clickable(locator))
        element.click()
        logger.info(f"Clicked element: {locator}")
    
    def wait_and_send_keys(self, locator: tuple, text: str, timeout: int = None):
        """Wait for element and send text"""
        if timeout is None:
            timeout = EXPLICIT_WAIT
        wait = WebDriverWait(self.driver, timeout)
        element = wait.until(EC.presence_of_element_located(locator))
        element.clear()
        element.send_keys(text)
        logger.info(f"Sent keys to element: {locator}")
    
    def get_element_text(self, locator: tuple, timeout: int = None) -> str:
        """Get element text"""
        element = self.wait_and_find(locator, timeout)
        return element.text
    
    def is_element_present(self, locator: tuple, timeout: int = 5) -> bool:
        """Check if element is present"""
        try:
            WebDriverWait(self.driver, timeout).until(
                EC.presence_of_element_located(locator)
            )
            return True
        except:
            return False
    
    def wait_for_url_change(self, old_url: str, timeout: int = None):
        """Wait for URL to change"""
        if timeout is None:
            timeout = EXPLICIT_WAIT
        wait = WebDriverWait(self.driver, timeout)
        wait.until(EC.url_changes(old_url))
        logger.info(f"URL changed from: {old_url}")
    
    def switch_to_frame(self, locator: tuple):
        """Switch to frame"""
        frame = self.wait_and_find(locator)
        self.driver.switch_to.frame(frame)
        logger.info(f"Switched to frame: {locator}")
    
    def switch_to_default_content(self):
        """Switch to default content"""
        self.driver.switch_to.default_content()
        logger.info("Switched to default content")
    
    def close_alert_if_present(self, timeout: int = 3) -> bool:
        """Close alert if present"""
        try:
            alert = WebDriverWait(self.driver, timeout).until(
                EC.alert_is_present()
            )
            alert.dismiss()
            logger.info("Alert dismissed")
            return True
        except:
            return False
    
    def get_current_url(self) -> str:
        """Get current URL"""
        return self.driver.current_url
    
    def refresh_page(self):
        """Refresh page"""
        self.driver.refresh()
        logger.info("Page refreshed")
    
    def go_back(self):
        """Go back in browser"""
        self.driver.back()
        logger.info("Navigated back")
    
    def scroll_to_element(self, locator: tuple):
        """Scroll to element"""
        element = self.wait_and_find(locator)
        self.driver.execute_script("arguments[0].scrollIntoView(true);", element)
        logger.info(f"Scrolled to element: {locator}")
    
    def execute_script(self, script: str, *args):
        """Execute JavaScript"""
        return self.driver.execute_script(script, *args)
