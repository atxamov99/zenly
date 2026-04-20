import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/friend_entity.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/chat/chat_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/main/main_shell.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/profile_setup/profile_setup_screen.dart';
import '../../presentation/screens/splash/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const profileSetup = '/profile-setup';
  static const home = '/home';
  static const map = '/map';
  static const main = '/main';
  static const chat = '/chat';
  static String chatFor(String friendId) => '/chat/$friendId';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final isAuth = authState.value != null;
      final isLoading = authState.isLoading;

      if (isLoading) return null;

      final loc = state.matchedLocation;

      if (!isAuth &&
          (loc == AppRoutes.map ||
              loc == AppRoutes.home ||
              loc == AppRoutes.main)) {
        return AppRoutes.login;
      }

      if (isAuth && loc == AppRoutes.login) {
        return AppRoutes.main;
      }

      if (isAuth && (loc == AppRoutes.home || loc == AppRoutes.map)) {
        return AppRoutes.main;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (_, __) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.map,
        builder: (_, __) => const MapScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (_, __) => const MainShell(),
      ),
      GoRoute(
        path: '${AppRoutes.chat}/:friendId',
        builder: (context, state) {
          final friend = state.extra as FriendEntity?;
          if (friend == null) {
            return const Scaffold(
              body: Center(child: Text('Friend not provided')),
            );
          }
          return ChatScreen(friend: friend);
        },
      ),
    ],
  );
});
