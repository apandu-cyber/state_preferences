import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    // Membungkus aplikasi dengan ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Memantau state tema dari UserProvider
    final isDarkMode = context.watch<UserProvider>().isDarkMode;

    return MaterialApp(
      title: 'State & Preferences',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),

      // Menerapkan Latihan 1: Tema berubah sesuai state
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
