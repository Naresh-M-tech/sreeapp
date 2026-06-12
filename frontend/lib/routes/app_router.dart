import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/auth_provider.dart';
import '../features/auth/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/participant/participant_shell.dart';
import '../features/participant/home_screen.dart';
import '../features/participant/event_list_screen.dart';
import '../features/participant/event_detail_screen.dart';
import '../features/participant/my_events_screen.dart';
import '../features/participant/notifications_screen.dart';
import '../features/participant/profile_screen.dart';
import '../features/participant/chat_screen.dart';
import '../features/organizer/organizer_dashboard.dart';
import '../features/organizer/create_event_screen.dart';
import '../features/organizer/manage_events_screen.dart';
import '../features/organizer/organizer_analytics_screen.dart';
import '../features/faculty/faculty_dashboard.dart';
import '../features/faculty/od_requests_screen.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/admin/user_management_screen.dart';
import '../features/admin/admin_events_screen.dart';
import '../features/admin/admin_analytics_screen.dart';
import '../features/admin/reports_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == '/login' || state.matchedLocation == '/register' || state.matchedLocation == '/forgot-password';
      final isSplash = state.matchedLocation == '/';

      if (authState.status == AuthStatus.initial) return '/';
      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && (isAuthRoute || isSplash)) {
        final user = authState.user;
        if (user == null) return '/login';
        if (user.isAdmin) return '/admin';
        if (user.isOrganizer) return '/organizer';
        if (user.isFaculty) return '/faculty';
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),

      // Participant routes
      ShellRoute(
        builder: (_, __, child) => ParticipantShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/events', builder: (_, __) => const EventListScreen()),
          GoRoute(path: '/events/:id', builder: (_, state) => EventDetailScreen(eventId: state.pathParameters['id']!)),
          GoRoute(path: '/my-events', builder: (_, __) => const MyEventsScreen()),
          GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/chat', builder: (_, __) => const ChatScreen()),
        ],
      ),

      // Organizer routes
      GoRoute(path: '/organizer', builder: (_, __) => const OrganizerDashboard()),
      GoRoute(path: '/organizer/create-event', builder: (_, __) => const CreateEventScreen()),
      GoRoute(path: '/organizer/manage-events', builder: (_, __) => const ManageEventsScreen()),
      GoRoute(path: '/organizer/analytics', builder: (_, __) => const OrganizerAnalyticsScreen()),

      // Faculty routes
      GoRoute(path: '/faculty', builder: (_, __) => const FacultyDashboard()),
      GoRoute(path: '/faculty/od-requests', builder: (_, __) => const OdRequestsScreen()),

      // Admin routes
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
      GoRoute(path: '/admin/users', builder: (_, __) => const UserManagementScreen()),
      GoRoute(path: '/admin/events', builder: (_, __) => const AdminEventsScreen()),
      GoRoute(path: '/admin/analytics', builder: (_, __) => const AdminAnalyticsScreen()),
      GoRoute(path: '/admin/reports', builder: (_, __) => const ReportsScreen()),
    ],
  );
});
