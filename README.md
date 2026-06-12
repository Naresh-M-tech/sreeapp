# Event Bridge 🌉

## Complete Event Management & Communication Platform for Colleges and Universities

### Built with Flutter + Spring Boot + MongoDB

---

## 🏗 Architecture

```
┌─────────────────────┐     ┌──────────────────────┐     ┌─────────────┐
│  Flutter Frontend   │────▶│  Spring Boot Backend  │────▶│  MongoDB    │
│  (Mobile/Web/Tab)   │◀────│  (REST + WebSocket)   │◀────│  Atlas      │
└─────────────────────┘     └──────────────────────┘     └─────────────┘
```

## 🚀 Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Flutter 3.x, Riverpod, GoRouter, Dio, Material 3 |
| Backend | Spring Boot 3.2, Java 17, Maven |
| Database | MongoDB Atlas |
| Auth | JWT (Access + Refresh Tokens) |
| Real-time | WebSocket + STOMP |
| PDF | OpenPDF |
| API Docs | Swagger/OpenAPI |
| DevOps | Docker, Docker Compose |

## 👥 User Roles

- **Admin** — Full system management, analytics, user/event management
- **Organizer** — Create/manage events, view analytics, manage registrations
- **Faculty** — Approve/reject OD requests, view student records
- **Participant** — Register for events, join teams, chat, receive notifications

## 📋 Features

### Authentication
- JWT Login/Register with BCrypt password hashing
- Refresh token rotation
- Email verification
- Forgot/Reset password
- Role-based access control

### Events
- CRUD with 7 categories (Technical, Cultural, Workshop, Hackathon, Seminar, Sports, Non-Technical)
- Admin approval workflow
- Team event support
- Registration with capacity tracking

### Teams
- Create/join teams with invite codes
- Leader controls
- Team size validation

### OD Management
- Student OD request submission
- Faculty approval/rejection workflow
- PDF letter generation

### Real-time Chat
- WebSocket/STOMP messaging
- Event chat rooms
- Direct messaging

### Analytics & Charts
- Admin: Users, Events, Revenue, Registrations
- Organizer: Event performance, registration trends
- Bar charts, Pie charts via fl_chart

### Notifications
- In-app notifications
- Email notifications (async)
- Mark read/unread

## 🏃‍♂️ Quick Start

### Prerequisites
- Java 17+
- Maven 3.8+
- Flutter 3.x
- MongoDB (local or Atlas)
- Docker (optional)

### Backend Setup

```bash
cd backend

# Set environment variable
export MONGO_URI=mongodb://localhost:27017/eventbridge

# Run
mvn spring-boot:run
```

Backend starts at `http://localhost:8080/api`
Swagger UI: `http://localhost:8080/api/swagger-ui.html`

### Frontend Setup

```bash
cd frontend

# Install dependencies
flutter pub get

# Run (mobile)
flutter run

# Run (web)
flutter run -d chrome

# Run (with custom API URL)
flutter run --dart-define=API_URL=http://localhost:8080/api
```

### Docker Deployment

```bash
# Copy and configure environment
cp .env.example .env

# Build and run
docker-compose up --build -d
```

- Frontend: http://localhost:3000
- Backend: http://localhost:8080/api
- MongoDB: localhost:27017

## 🔐 Default Admin Credentials

```
Email: admin@eventbridge.com
Password: Admin@123
```

## 📁 Project Structure

### Backend
```
backend/src/main/java/com/eventbridge/
├── EventBridgeApplication.java
├── config/          # Security, WebSocket, OpenAPI, DataInit
├── controller/      # REST + WebSocket controllers
├── dto/             # Request/Response DTOs
├── exception/       # Global exception handling
├── model/           # MongoDB entities
├── repository/      # MongoDB repositories
├── security/        # JWT provider, filter, UserDetailsService
└── service/         # Business logic
```

### Frontend
```
frontend/lib/
├── main.dart
├── core/
│   ├── services/    # API client, Auth provider
│   └── theme/       # Material 3 theme
├── features/
│   ├── auth/        # Login, Register, Forgot Password, Splash
│   ├── participant/ # Home, Events, Chat, Profile, Notifications
│   ├── organizer/   # Dashboard, Create/Manage Events, Analytics
│   ├── faculty/     # Dashboard, OD Requests
│   └── admin/       # Dashboard, Users, Events, Analytics, Reports
├── models/          # Data models
└── routes/          # GoRouter configuration
```

## 🧪 Testing

```bash
# Backend tests
cd backend && mvn test

# Flutter tests
cd frontend && flutter test
```

## 📡 API Endpoints

| Endpoint | Description |
|----------|-------------|
| POST /auth/register | Register new user |
| POST /auth/login | Login |
| POST /auth/refresh | Refresh token |
| POST /auth/forgot-password | Request password reset |
| GET /events/public/published | Get published events |
| POST /events | Create event |
| POST /registrations/{eventId} | Register for event |
| POST /teams | Create team |
| GET /notifications | Get notifications |
| GET /chat/rooms | Get chat rooms |
| POST /od | Create OD request |
| GET /admin/analytics | Admin analytics |
| GET /organizer/analytics | Organizer analytics |

## 📄 License

MIT License
