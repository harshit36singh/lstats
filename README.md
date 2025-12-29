# LStats - LeetCode Statistics Tracker

A comprehensive LeetCode statistics tracking application built with Flutter and Spring Boot that helps developers monitor their coding progress, compete with friends, and stay motivated.

## 🌟 Features

### 📊 Statistics & Analytics
- **Real-time LeetCode Stats**: Track your solved problems, acceptance rate, and ranking
- **Progress Visualization**: Interactive heatmaps showing your daily coding activity
- **Performance Metrics**: Monitor your performance across Easy, Medium, and Hard problems
- **Historical Tracking**: View your progress over time with detailed analytics

### 👥 Social Features
- **Friend System**: Add friends and compare your progress
- **Friend Requests**: Send and receive friend requests with notifications
- **Leaderboards**: 
  - Global leaderboard to compete with all users
  - College-specific leaderboards to compete with peers
  - Friend-based leaderboards for friendly competition
- **Groups**: Create and join groups to collaborate and compete with specific communities

### 💬 Communication
- **Real-time Chat**: Global chat system with WebSocket support
- **Private Messaging**: Direct messaging with friends
- **Chat Management**: Automatic cleanup to maintain only 100MB of chat history
- **Online Presence**: See which friends are currently active

### 🔔 Notifications
- **Real-time Notifications**: Get instant updates on friend requests, group invites, and messages
- **Notification Center**: Centralized notification management
- **Push Notifications**: Stay updated even when the app is closed

### 🎨 User Interface
- **Modern Material Design**: Clean and intuitive interface
- **Dark Mode Support**: Easy on the eyes during late-night coding sessions
- **Responsive Layout**: Optimized for different screen sizes
- **Smooth Animations**: Fluid transitions and interactions

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter (Dart)
- **State Management**: Provider/Bloc pattern
- **Real-time Communication**: WebSocket (STOMP)
- **HTTP Client**: Dio for API calls
- **Local Storage**: SharedPreferences for user data

### Backend (Spring Boot)
- **Framework**: Spring Boot (Java 17)
- **Database**: PostgreSQL/MySQL
- **Authentication**: JWT-based authentication
- **WebSocket**: STOMP over WebSocket for real-time features
- **Security**: Spring Security with custom configurations
- **Scheduling**: Automatic chat cleanup and data maintenance

## 📱 Screenshots

### 📸 App Overview
![LStats App Screenshot](frontend/lstats/lib/screenshot/lstatsall.png)


## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Java 17 or higher
- PostgreSQL/MySQL
- Android Studio / VS Code
- Git

### Backend Setup

1. **Clone the repository**
```bash
git clone https://github.com/harshit36singh/lstats.git
cd lstats/backend/lstats
```

2. **Configure the database**
Edit `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/lstats
spring.datasource.username=your_username
spring.datasource.password=your_password
```

3. **Build and run**
```bash
# Using Maven wrapper (Unix/Mac)
./mvnw spring-boot:run

# Using Maven wrapper (Windows)
mvnw.cmd spring-boot:run
```

The backend will start on `http://localhost:8080`

### Frontend Setup

1. **Navigate to frontend directory**
```bash
cd frontend/lstats
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
Update the API base URL in your configuration file to point to your backend server.

4. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run -d ios

# For Web
flutter run -d chrome
```

## 🔧 Configuration

### Backend Configuration

Key configuration options in `application.properties`:

```properties
# Server Configuration
server.port=8080

# Database Configuration
spring.datasource.url=jdbc:postgresql://localhost:5432/lstats
spring.jpa.hibernate.ddl-auto=update

# JWT Configuration
jwt.secret=your-secret-key
jwt.expiration=86400000

# WebSocket Configuration
spring.websocket.enabled=true
```

### Frontend Configuration

Update API endpoints in your configuration file:
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-backend-url:8080';
  static const String wsUrl = 'ws://your-backend-url:8080/ws';
}
```

## 📦 Project Structure

```
lstats/
├── backend/
│   └── lstats/
│       ├── src/
│       │   ├── main/
│       │   │   ├── java/com/example/lstats/
│       │   │   │   ├── auth/          # Authentication & Security
│       │   │   │   ├── model/         # Data models
│       │   │   │   ├── repository/    # Database repositories
│       │   │   │   ├── service/       # Business logic
│       │   │   │   └── listener/      # Event listeners
│       │   │   └── resources/
│       │   │       └── application.properties
│       │   └── test/
│       └── pom.xml
└── frontend/
    └── lstats/
        ├── lib/
        │   ├── views/           # UI screens
        │   ├── services/        # API & business logic
        │   ├── models/          # Data models
        │   └── main.dart
        └── pubspec.yaml
```

## 🔑 Key Features Implementation

### Real-time Features
- **WebSocket Connection**: STOMP protocol over WebSocket for bidirectional communication
- **Presence System**: Track online/offline status of users
- **Live Updates**: Instant notifications and chat messages

### Security
- **JWT Authentication**: Secure token-based authentication
- **Password Encryption**: BCrypt password hashing
- **CORS Configuration**: Properly configured for cross-origin requests
- **Input Validation**: Server-side validation for all inputs

### Performance Optimization
- **Chat Cleanup**: Scheduled task to maintain chat history at 100MB
- **Database Indexing**: Optimized queries for faster data retrieval
- **Caching**: Strategic caching for frequently accessed data
- **Lazy Loading**: Efficient data loading in the frontend

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 API Documentation

### Authentication Endpoints
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/profile` - Get user profile

### Friend Endpoints
- `GET /api/friends` - Get friend list
- `POST /api/friends/request` - Send friend request
- `POST /api/friends/accept/{id}` - Accept friend request
- `DELETE /api/friends/{id}` - Remove friend

### Leaderboard Endpoints
- `GET /api/leaderboard/global` - Get global leaderboard
- `GET /api/leaderboard/college/{collegeName}` - Get college leaderboard
- `GET /api/leaderboard/friends` - Get friends leaderboard

### Group Endpoints
- `GET /api/groups` - Get user groups
- `POST /api/groups` - Create new group
- `POST /api/groups/{id}/invite` - Invite user to group
- `GET /api/groups/{id}/members` - Get group members

### Notification Endpoints
- `GET /api/notifications` - Get user notifications
- `PUT /api/notifications/{id}/read` - Mark notification as read
- `DELETE /api/notifications/{id}` - Delete notification

### WebSocket Endpoints
- `/ws` - WebSocket connection endpoint
- `/app/chat.send` - Send chat message
- `/topic/chat` - Subscribe to chat messages
- `/user/queue/notifications` - Subscribe to personal notifications


## 👥 Contributors

- [Harshit Singh](https://github.com/harshit36singh) - Primary Developer
- [HarshitSingh3636](https://github.com/HarshitSingh3636) - Contributor




