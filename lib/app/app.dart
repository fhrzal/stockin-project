import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/auth/provider/auth_provider.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import 'theme.dart';
import '../features/navigation/presentation/main_navigation_page.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'Smart Warehouse Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: StreamBuilder(
        stream: authProvider.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return const MainNavigationPage();
          }

          return const LoginPage();
        },
      ),
    );
  }
}