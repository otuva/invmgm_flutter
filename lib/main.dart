import 'dart:io';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invmgm_flutter/screens/main_screen.dart';

// ignore certs
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  runApp(const ProviderScope(child: InvMgmApp()));
}

class InvMgmApp extends StatelessWidget {
  const InvMgmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: FlexThemeData.light(scheme: FlexScheme.deepPurple),
      darkTheme: FlexThemeData.dark(scheme: FlexScheme.deepPurple),
      themeMode: ThemeMode.system,
      home: const MainScreen(),
    );
  }
}
