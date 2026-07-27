import 'package:flutter/material.dart';

import 'ui/home_page.dart';

class NotificationClientApp extends StatelessWidget {
  const NotificationClientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notification Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const HomePage(),
    );
  }
}
