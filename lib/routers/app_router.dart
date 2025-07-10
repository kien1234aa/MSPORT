// lib/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:msport/model/user.dart';
import 'package:msport/pages/HomePage.dart';
import 'package:msport/pages/LoginPage.dart';
import 'package:msport/pages/StartPage.dart';
import 'package:msport/pages/RegisterPage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

GoRouter appRouter({required bool isFirstLaunch}) {
  return GoRouter(
    initialLocation: isFirstLaunch ? '/start' : '/',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Nếu đang ở /start thì không redirect nữa
      if (state.matchedLocation == '/start') return null;

      if (!isLoggedIn && !isAuthPage) return '/login';
      if (isLoggedIn && isAuthPage) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const StartPage(), // hoặc HomePage
      ),
      GoRoute(path: '/start', builder: (context, state) => const StartPage()),
      GoRoute(path: '/login', builder: (context, state) => const Loginpage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final userData = state.extra as User1?;
          return HomePage(user: userData);
        },
      ),
    ],
  );
}
