import 'package:go_router/go_router.dart';
import 'package:web_admin/providers/user_data_provider.dart';
import 'package:web_admin/views/screens/dashboard_screen.dart';
import 'package:web_admin/views/screens/error_screen.dart';
import 'package:web_admin/views/screens/login_screen.dart';
import 'package:web_admin/views/screens/logout_screen.dart';
import 'package:web_admin/views/screens/my_profile_screen.dart';
import 'package:web_admin/views/screens/register_screen.dart';
import 'package:web_admin/views/screens/scooter_detail_screen.dart';
import 'package:web_admin/views/screens/scooters_screen.dart';
import 'package:web_admin/views/screens/user_detail_screen.dart';
import 'package:web_admin/views/screens/users_screen.dart';

class RouteUri {
  static const String home = '/';
  static const String dashboard = '/dashboard';
  static const String myProfile = '/my-profile';
  static const String logout = '/logout';
  static const String error404 = '/404';
  static const String login = '/login';
  static const String register = '/register';
  static const String userDetail = '/user-detail';
  static const String scooters = '/scooters'; // Add this constant
  static const String scooterDetail = '/scooter-detail';
  static const String users = '/users'; // Add this constant
}

const List<String> unrestrictedRoutes = [
  RouteUri.error404,
  RouteUri.logout,
];

const List<String> publicRoutes = [
  RouteUri.login,
  RouteUri.register,
];

GoRouter appRouter(UserDataProvider userDataProvider) {
  return GoRouter(
    initialLocation: RouteUri.home,
    errorPageBuilder: (context, state) => NoTransitionPage<void>(
      key: state.pageKey,
      child: const ErrorScreen(),
    ),
    routes: [
      GoRoute(
        path: RouteUri.home,
        redirect: (context, state) => RouteUri.dashboard,
      ),
      GoRoute(
        path: RouteUri.dashboard,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const DashboardScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.myProfile,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MyProfileScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.logout,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LogoutScreen(),
        ),
      ),

      GoRoute(
        path: RouteUri.login,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.register,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: const RegisterScreen(),
          );
        },
      ),

      GoRoute(
        path: RouteUri.userDetail,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: UserDetailScreen(id: state.uri.queryParameters['id'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.scooterDetail,
        pageBuilder: (context, state) {
          return NoTransitionPage<void>(
            key: state.pageKey,
            child: ScooterDetailScreen(id: state.uri.queryParameters['id'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: RouteUri.scooters,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const ScooterScreen(),
        ),
      ),
      GoRoute(
        path: RouteUri.users,
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const UserScreen(),
        ),
      ),
    ],
    redirect: (context, state) {
      if (unrestrictedRoutes.contains(state.matchedLocation)) {
        return null;
      } else if (publicRoutes.contains(state.matchedLocation)) {
        // Is public route.
        if (userDataProvider.isUserLoggedIn()) {
          // User is logged in, redirect to home page.
          return RouteUri.home;
        }
      } else {
        // Not public route.
        if (!userDataProvider.isUserLoggedIn()) {
          // User is not logged in, redirect to login page.
          return RouteUri.login;
        }
      }

      return null;
    },
  );
}
