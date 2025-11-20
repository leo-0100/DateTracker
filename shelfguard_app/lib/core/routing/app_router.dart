import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/products/presentation/pages/product_list_page.dart';
import '../../features/products/presentation/pages/product_detail_page.dart';
import '../../features/products/presentation/pages/add_product_page.dart';
import '../../features/products/presentation/pages/scan_product_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppRouter {
  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: '/login',
      refreshListenable: _AuthStateNotifier(authBloc),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is Authenticated;
        final isAuthRoute = state.matchedLocation == '/login' ||
                           state.matchedLocation == '/signup';

        // If not authenticated and trying to access protected route, redirect to login
        if (!isAuthenticated && !isAuthRoute) {
          return '/login';
        }

        // If authenticated and on auth route, redirect to dashboard
        if (isAuthenticated && isAuthRoute) {
          return '/dashboard';
        }

        // No redirect needed
        return null;
      },
      routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SignupPage(),
        ),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const DashboardPage(),
        ),
      ),
      GoRoute(
        path: '/products',
        name: 'products',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ProductListPage(),
        ),
      ),
      GoRoute(
        path: '/products/add',
        name: 'add-product',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const AddProductPage(),
        ),
      ),
      GoRoute(
        path: '/products/scan',
        name: 'scan-product',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const ScanProductPage(),
        ),
      ),
      GoRoute(
        path: '/products/:id',
        name: 'product-detail',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: ProductDetailPage(productId: id),
          );
        },
      ),
      GoRoute(
        path: '/products/:id/edit',
        name: 'edit-product',
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          return _buildPageWithTransition(
            context: context,
            state: state,
            child: AddProductPage(productId: id),
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        pageBuilder: (context, state) => _buildPageWithTransition(
          context: context,
          state: state,
          child: const SettingsPage(),
        ),
      ),
    ],
  );

  static CustomTransitionPage _buildPageWithTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);
        var fadeAnimation = animation.drive(
          Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: curve),
          ),
        );

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
    );
  }
}

/// Auth state notifier for GoRouter to listen to authentication changes
class _AuthStateNotifier extends ChangeNotifier {
  final AuthBloc _authBloc;

  _AuthStateNotifier(this._authBloc) {
    _authBloc.stream.listen((_) {
      notifyListeners();
    });
  }
}
