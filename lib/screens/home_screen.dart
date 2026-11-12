import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Membaca dan memantau perubahan state dari UserProvider
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Tombol toggle tema (Latihan 1)
          IconButton(
            icon: Icon(
              provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            tooltip: 'Ganti Tema',
            onPressed: () {
              provider.toggleTheme(!provider.isDarkMode);
            },
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.home, size: 80, color: Colors.deepPurple),
                    const SizedBox(height: 24),
                    Text(
                      provider.user.isLoggedIn
                          ? 'Selamat datang, ${provider.user.name}!'
                          : 'Selamat datang, Tamu!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    if (provider.user.isLoggedIn) ...[
                      Text(
                        'Email: ${provider.user.email}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person),
                        label: const Text('Lihat Profil'),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Login / Daftar'),
                      ),
                    ],

                    const SizedBox(height: 48),
                    // Indikator Counter Kunjungan (Latihan 2)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: provider.isDarkMode
                            ? Colors.grey[800]
                            : Colors.amber[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Aplikasi dibuka: ${provider.visitCount} kali',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: provider.isDarkMode
                              ? Colors.white70
                              : Colors.brown[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
