import 'view/page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/';
  static const String splash = '/splash';

  static Map<String, WidgetBuilder> get routes => {
    home: (context) => const HomePage(),
    splash: (context) => const SplashPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    return null;
  }

  static Future<void> pushReplacementNamed(
    BuildContext context,
    String name, {
    Object? arguments,
  }) async {
    await Navigator.pushReplacementNamed(context, name, arguments: arguments);
  }

  static Future<void> goFromSplash(BuildContext context) async {
    await pushReplacementNamed(context, home);
  }
}
