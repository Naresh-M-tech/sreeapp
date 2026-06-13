"""
API Client for EventBridge Backend Testing
"""
import logging
import requests
from typing import Dict, Any, Optional
from requests.auth import HTTPBearerAuth
import json

from framework.config import BACKEND_BASE_URL, API_TIMEOUT, API_RETRY_ATTEMPTS, API_RETRY_DELAY

logger = logging.getLogger(__name__)


class APIClient:
    """API Client for backend testing"""
    
    def __init__(self, base_url: str = BACKEND_BASE_URL):
        self.base_url = base_url
        self.session = requests.Session()
        self.access_token = None
        self.refresh_token = None
        self.headers = {
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
    
    def set_auth_token(self, access_token: str, refresh_token: str = None):
        """Set authentication token"""
        self.access_token = access_token
        if refresh_token:
            self.refresh_token = refresh_token
        self.headers["Authorization"] = f"Bearer {access_token}"
        logger.info("Authentication token set")
    
    def clear_auth(self):
        """Clear authentication"""
        self.access_token = None
        self.refresh_token = None
        self.headers.pop("Authorization", None)
        logger.info("Authentication cleared")
    
    def _get_headers(self) -> Dict[str, str]:
        """Get request headers"""
        return self.headers.copy()
    
    def _make_request(self, method: str, endpoint: str, **kwargs) -> requests.Response:
        """Make HTTP request"""
        url = f"{self.base_url}{endpoint}"
        headers = self._get_headers()
        
        try:
            logger.info(f"{method} {url}")
            response = self.session.request(
                method=method,
                url=url,
                headers=headers,
                timeout=API_TIMEOUT,
                **kwargs
            )
            
            logger.info(f"Response Status: {response.status_code}")
            if response.text:
                logger.debug(f"Response Body: {response.text[:500]}")
            
            return response
        
        except Exception as e:
            logger.error(f"Request failed: {e}")
            raise
    
    def get(self, endpoint: str, params: Dict = None, **kwargs) -> requests.Response:
        """GET request"""
        return self._make_request("GET", endpoint, params=params, **kwargs)
    
    def post(self, endpoint: str, data: Dict = None, json_data: Dict = None, **kwargs) -> requests.Response:
        """POST request"""
        if json_data:
            return self._make_request("POST", endpoint, json=json_data, **kwargs)
        return self._make_request("POST", endpoint, data=data, **kwargs)
    
    def put(self, endpoint: str, data: Dict = None, json_data: Dict = None, **kwargs) -> requests.Response:
        """PUT request"""
        if json_data:
            return self._make_request("PUT", endpoint, json=json_data, **kwargs)
        return self._make_request("PUT", endpoint, data=data, **kwargs)
    
    def delete(self, endpoint: str, **kwargs) -> requests.Response:
        """DELETE request"""
        return self._make_request("DELETE", endpoint, **kwargs)
    
    def patch(self, endpoint: str, data: Dict = None, json_data: Dict = None, **kwargs) -> requests.Response:
        """PATCH request"""
        if json_data:
            return self._make_request("PATCH", endpoint, json=json_data, **kwargs)
        return self._make_request("PATCH", endpoint, data=data, **kwargs)
    
    # Authentication APIs
    def register(self, email: str, password: str, name: str, role: str = "PARTICIPANT") -> requests.Response:
        """Register new user"""
        data = {
            "email": email,
            "password": password,
            "name": name,
            "role": role
        }
        return self.post("/auth/register", json_data=data)
    
    def login(self, email: str, password: str) -> requests.Response:
        """Login user"""
        data = {
            "email": email,
            "password": password
        }
        return self.post("/auth/login", json_data=data)
    
    def refresh_access_token(self) -> requests.Response:
        """Refresh access token"""
        data = {"refreshToken": self.refresh_token}
        return self.post("/auth/refresh", json_data=data)
    
    def logout(self) -> requests.Response:
        """Logout user"""
        return self.post("/auth/logout")
    
    def forgot_password(self, email: str) -> requests.Response:
        """Request password reset"""
        data = {"email": email}
        return self.post("/auth/forgot-password", json_data=data)
    
    def reset_password(self, token: str, new_password: str) -> requests.Response:
        """Reset password"""
        data = {
            "token": token,
            "newPassword": new_password
        }
        return self.post("/auth/reset-password", json_data=data)
    
    def verify_email(self, token: str) -> requests.Response:
        """Verify email"""
        return self.get("/auth/verify", params={"token": token})
    
    # Event APIs
    def create_event(self, event_data: Dict) -> requests.Response:
        """Create event"""
        return self.post("/events", json_data=event_data)
    
    def get_event(self, event_id: str) -> requests.Response:
        """Get event details"""
        return self.get(f"/events/{event_id}")
    
    def update_event(self, event_id: str, event_data: Dict) -> requests.Response:
        """Update event"""
        return self.put(f"/events/{event_id}", json_data=event_data)
    
    def delete_event(self, event_id: str) -> requests.Response:
        """Delete event"""
        return self.delete(f"/events/{event_id}")
    
    def get_published_events(self, page: int = 0, size: int = 10) -> requests.Response:
        """Get published events"""
        return self.get("/events/public/published", params={"page": page, "size": size})
    
    def search_events(self, query: str) -> requests.Response:
        """Search events"""
        return self.get("/events/public/search", params={"query": query})
    
    def get_events_by_category(self, category: str) -> requests.Response:
        """Get events by category"""
        return self.get(f"/events/public/category/{category}")
    
    def get_my_events(self) -> requests.Response:
        """Get user's events"""
        return self.get("/events/my")
    
    # Registration APIs
    def register_for_event(self, event_id: str) -> requests.Response:
        """Register for event"""
        return self.post(f"/registrations/{event_id}")
    
    def cancel_registration(self, registration_id: str) -> requests.Response:
        """Cancel registration"""
        return self.delete(f"/registrations/{registration_id}")
    
    def get_my_registrations(self) -> requests.Response:
        """Get user's registrations"""
        return self.get("/registrations/my")
    
    # User APIs
    def get_current_user(self) -> requests.Response:
        """Get current user"""
        return self.get("/users/me")
    
    def update_current_user(self, user_data: Dict) -> requests.Response:
        """Update current user"""
        return self.put("/users/me", json_data=user_data)
    
    def get_user(self, user_id: str) -> requests.Response:
        """Get user by ID"""
        return self.get(f"/users/{user_id}")
    
    def search_users(self, name: str) -> requests.Response:
        """Search users"""
        return self.get("/users/search", params={"name": name})
    
    # Team APIs
    def create_team(self, event_id: str, team_name: str) -> requests.Response:
        """Create team"""
        return self.post("/teams", params={"eventId": event_id, "teamName": team_name})
    
    def join_team(self, team_id: str) -> requests.Response:
        """Join team"""
        return self.post(f"/teams/{team_id}/join")
    
    def get_team(self, team_id: str) -> requests.Response:
        """Get team details"""
        return self.get(f"/teams/{team_id}")
    
    def get_event_teams(self, event_id: str) -> requests.Response:
        """Get event teams"""
        return self.get(f"/teams/event/{event_id}")
    
    def get_my_teams(self) -> requests.Response:
        """Get user's teams"""
        return self.get("/teams/my")
    
    # Notification APIs
    def get_notifications(self) -> requests.Response:
        """Get all notifications"""
        return self.get("/notifications")
    
    def get_unread_notifications(self) -> requests.Response:
        """Get unread notifications"""
        return self.get("/notifications/unread")
    
    def get_unread_count(self) -> requests.Response:
        """Get unread notifications count"""
        return self.get("/notifications/unread/count")
    
    def mark_notification_as_read(self, notification_id: str) -> requests.Response:
        """Mark notification as read"""
        return self.put(f"/notifications/{notification_id}/read")
    
    def mark_all_notifications_as_read(self) -> requests.Response:
        """Mark all notifications as read"""
        return self.put("/notifications/read-all")
    
    # OD Request APIs
    def create_od_request(self, od_data: Dict) -> requests.Response:
        """Create OD request"""
        return self.post("/od", json_data=od_data)
    
    def get_my_od_requests(self) -> requests.Response:
        """Get user's OD requests"""
        return self.get("/od/student")
    
    def get_pending_od_requests(self) -> requests.Response:
        """Get pending OD requests (Faculty)"""
        return self.get("/od/faculty/pending")
    
    def approve_od_request(self, od_id: str, remarks: str = "") -> requests.Response:
        """Approve OD request"""
        data = {"remarks": remarks}
        return self.put(f"/od/{od_id}/approve", json_data=data)
    
    def reject_od_request(self, od_id: str, remarks: str) -> requests.Response:
        """Reject OD request"""
        data = {"remarks": remarks}
        return self.put(f"/od/{od_id}/reject", json_data=data)
    
    def download_od_pdf(self, od_id: str) -> requests.Response:
        """Download OD as PDF"""
        return self.get(f"/od/{od_id}/pdf")
    
    # Analytics APIs
    def get_admin_analytics(self) -> requests.Response:
        """Get admin analytics"""
        return self.get("/admin/analytics")
    
    def get_organizer_analytics(self) -> requests.Response:
        """Get organizer analytics"""
        return self.get("/organizer/analytics")
    
    # Admin APIs
    def get_all_users(self) -> requests.Response:
        """Get all users"""
        return self.get("/admin/users")
    
    def get_users_by_role(self, role: str) -> requests.Response:
        """Get users by role"""
        return self.get(f"/admin/users/role/{role}")
    
    def toggle_user_status(self, user_id: str) -> requests.Response:
        """Toggle user status"""
        return self.put(f"/admin/users/{user_id}/toggle-status")
    
    def delete_user(self, user_id: str) -> requests.Response:
        """Delete user"""
        return self.delete(f"/admin/users/{user_id}")
    
    def get_pending_events(self) -> requests.Response:
        """Get pending events"""
        return self.get("/admin/events/pending")
    
    def approve_event(self, event_id: str) -> requests.Response:
        """Approve event"""
        return self.put(f"/admin/events/{event_id}/approve")
    
    def reject_event(self, event_id: str, reason: str) -> requests.Response:
        """Reject event"""
        return self.put(f"/admin/events/{event_id}/reject", params={"reason": reason})
