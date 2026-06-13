"""
Utilities for Test Framework
"""
import logging
import json
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any
from faker import Faker
from dataclasses import dataclass, asdict

fake = Faker()
logger = logging.getLogger(__name__)


@dataclass
class TestResult:
    """Test result data class"""
    test_id: str
    module: str
    scenario: str
    expected_result: str
    actual_result: str
    status: str  # PASSED, FAILED, SKIPPED
    execution_time: float
    screenshot_path: str = None
    error_message: str = None
    
    def to_dict(self) -> Dict:
        return asdict(self)


@dataclass
class BugReport:
    """Bug report data class"""
    bug_id: str
    module: str
    description: str
    steps_to_reproduce: str
    severity: str  # High, Medium, Low
    status: str  # New, In Progress, Fixed, Closed
    screenshot_path: str = None
    
    def to_dict(self) -> Dict:
        return asdict(self)


class TestDataGenerator:
    """Generate test data"""
    
    @staticmethod
    def generate_user_data(role: str = "PARTICIPANT") -> Dict:
        """Generate user data"""
        return {
            "email": fake.email(),
            "password": "Test@123456",
            "name": fake.name(),
            "role": role
        }
    
    @staticmethod
    def generate_event_data() -> Dict:
        """Generate event data"""
        return {
            "title": fake.catch_phrase(),
            "description": fake.text(),
            "category": fake.random_element(["Technical", "Cultural", "Workshop", "Hackathon"]),
            "startDate": datetime.now().isoformat(),
            "endDate": datetime.now().isoformat(),
            "capacity": fake.random_int(min=10, max=500),
            "location": fake.address()
        }
    
    @staticmethod
    def generate_team_data() -> Dict:
        """Generate team data"""
        return {
            "name": fake.company(),
            "description": fake.text()
        }
    
    @staticmethod
    def generate_od_request_data() -> Dict:
        """Generate OD request data"""
        return {
            "eventId": fake.uuid4(),
            "reason": fake.text(),
            "startDate": datetime.now().isoformat(),
            "endDate": datetime.now().isoformat(),
            "isMultipleDays": True
        }


class ReportGenerator:
    """Generate test reports"""
    
    @staticmethod
    def generate_test_report(results: List[TestResult], output_path: Path) -> str:
        """Generate HTML test report"""
        html_content = """
        <html>
        <head>
            <title>Test Execution Report</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                h1 { color: #333; }
                table { border-collapse: collapse; width: 100%; margin-top: 20px; }
                th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
                th { background-color: #4CAF50; color: white; }
                tr:nth-child(even) { background-color: #f2f2f2; }
                .PASSED { color: green; font-weight: bold; }
                .FAILED { color: red; font-weight: bold; }
                .SKIPPED { color: orange; font-weight: bold; }
                .summary { margin-top: 20px; padding: 10px; background-color: #f9f9f9; }
            </style>
        </head>
        <body>
            <h1>Test Execution Report</h1>
            <p>Generated: {timestamp}</p>
            <div class="summary">
                <h2>Summary</h2>
                <p>Total Tests: {total}</p>
                <p>Passed: {passed}</p>
                <p>Failed: {failed}</p>
                <p>Skipped: {skipped}</p>
                <p>Pass Rate: {pass_rate}%</p>
            </div>
            <table>
                <tr>
                    <th>Test ID</th>
                    <th>Module</th>
                    <th>Scenario</th>
                    <th>Status</th>
                    <th>Execution Time (s)</th>
                    <th>Error</th>
                </tr>
                {rows}
            </table>
        </body>
        </html>
        """
        
        # Calculate statistics
        total = len(results)
        passed = sum(1 for r in results if r.status == "PASSED")
        failed = sum(1 for r in results if r.status == "FAILED")
        skipped = sum(1 for r in results if r.status == "SKIPPED")
        pass_rate = (passed / total * 100) if total > 0 else 0
        
        # Generate rows
        rows = ""
        for result in results:
            rows += f"""
            <tr>
                <td>{result.test_id}</td>
                <td>{result.module}</td>
                <td>{result.scenario}</td>
                <td class="{result.status}">{result.status}</td>
                <td>{result.execution_time:.2f}</td>
                <td>{result.error_message or ''}</td>
            </tr>
            """
        
        html_content = html_content.format(
            timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            total=total,
            passed=passed,
            failed=failed,
            skipped=skipped,
            pass_rate=f"{pass_rate:.2f}",
            rows=rows
        )
        
        # Write to file
        with open(output_path, "w") as f:
            f.write(html_content)
        
        logger.info(f"Report generated: {output_path}")
        return str(output_path)


class CodeAuditHelper:
    """Helper for code audit"""
    
    @staticmethod
    def find_todo_comments(file_path: Path) -> List[Dict]:
        """Find TODO and FIXME comments"""
        todos = []
        try:
            with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
                for line_num, line in enumerate(lines, 1):
                    if 'TODO' in line or 'FIXME' in line:
                        todos.append({
                            'file': str(file_path),
                            'line': line_num,
                            'content': line.strip()
                        })
        except Exception as e:
            logger.error(f"Error reading file {file_path}: {e}")
        
        return todos
    
    @staticmethod
    def analyze_file_size(file_path: Path) -> Dict:
        """Analyze file size"""
        try:
            size = file_path.stat().st_size
            return {
                'file': str(file_path),
                'size_bytes': size,
                'size_kb': size / 1024,
                'large': size > 500000  # 500 KB
            }
        except Exception as e:
            logger.error(f"Error analyzing file {file_path}: {e}")
            return None


class PerformanceHelper:
    """Helper for performance testing"""
    
    @staticmethod
    def measure_page_load_time(driver, url: str) -> float:
        """Measure page load time"""
        import time
        start_time = time.time()
        driver.get(url)
        end_time = time.time()
        load_time = end_time - start_time
        logger.info(f"Page load time for {url}: {load_time:.2f}s")
        return load_time
    
    @staticmethod
    def measure_api_response_time(response) -> float:
        """Measure API response time"""
        return response.elapsed.total_seconds()


class AccessibilityHelper:
    """Helper for accessibility testing"""
    
    @staticmethod
    def check_alt_text_in_images(driver) -> List[Dict]:
        """Check alt text in images"""
        images = driver.find_elements("tag name", "img")
        results = []
        for img in images:
            alt_text = img.get_attribute("alt")
            src = img.get_attribute("src")
            results.append({
                'src': src,
                'alt_text': alt_text,
                'has_alt': bool(alt_text)
            })
        return results
    
    @staticmethod
    def check_form_labels(driver) -> List[Dict]:
        """Check form labels"""
        inputs = driver.find_elements("tag name", "input")
        results = []
        for input_elem in inputs:
            label_elem = driver.find_elements("xpath", f"//label[@for='{input_elem.get_attribute('id')}']")
            results.append({
                'input_id': input_elem.get_attribute('id'),
                'input_type': input_elem.get_attribute('type'),
                'has_label': len(label_elem) > 0
            })
        return results
    
    @staticmethod
    def check_color_contrast(driver) -> List[Dict]:
        """Check color contrast (basic implementation)"""
        results = []
        elements = driver.find_elements("xpath", "//*[@style]")
        for elem in elements[:10]:  # Check first 10 elements with styles
            results.append({
                'element': elem.tag_name,
                'text': elem.text[:50] if elem.text else 'N/A',
                'note': 'Manual review recommended'
            })
        return results


class SecurityHelper:
    """Helper for security testing"""
    
    @staticmethod
    def check_ssl_certificate(url: str) -> Dict:
        """Check SSL certificate"""
        import ssl
        try:
            hostname = url.replace("https://", "").replace("http://", "").split('/')[0]
            context = ssl.create_default_context()
            with ssl.create_connection((hostname, 443), timeout=5) as sock:
                with context.wrap_socket(sock, server_hostname=hostname) as ssock:
                    cert = ssock.getpeercert()
                    return {
                        'hostname': hostname,
                        'has_certificate': True,
                        'certificate_info': cert
                    }
        except Exception as e:
            logger.error(f"SSL check failed: {e}")
            return {
                'hostname': url,
                'has_certificate': False,
                'error': str(e)
            }
    
    @staticmethod
    def check_security_headers(response) -> Dict:
        """Check security headers"""
        headers = response.headers
        return {
            'content_security_policy': headers.get('Content-Security-Policy', 'Not set'),
            'x_frame_options': headers.get('X-Frame-Options', 'Not set'),
            'x_content_type_options': headers.get('X-Content-Type-Options', 'Not set'),
            'strict_transport_security': headers.get('Strict-Transport-Security', 'Not set'),
            'x_xss_protection': headers.get('X-XSS-Protection', 'Not set')
        }
