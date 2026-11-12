import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  // Controller & State untuk Latihan 3: Daftar Favorit
  final TextEditingController _favController = TextEditingController();
  List<String> _favorites = [];

  bool _isInit = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final provider = context.read<UserProvider>();
      _nameController = TextEditingController(text: provider.user.name);
      _emailController = TextEditingController(text: provider.user.email);
      _loadFavorites();
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _favController.dispose();
    super.dispose();
  }

  // --- Fungsi Latihan 3 (Daftar Favorit) ---
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites') ?? [];
    });
  }

  Future<void> _addFavorite() async {
    if (_favController.text.trim().isNotEmpty) {
      setState(() {
        _favorites.add(_favController.text.trim());
        _favController.clear();
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorites', _favorites);
    }
  }

  Future<void> _removeFavorite(int index) async {
    setState(() {
      _favorites.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', _favorites);
  }
  // ------------------------------------------

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // --- Latihan 5: Validasi Keamanan ---
      final dangerRegex = RegExp(r'[<>/*;]');
      if (dangerRegex.hasMatch(name)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Nama mengandung karakter berbahaya!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Cek apakah email sama dengan yang sudah tersimpan di SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email') ?? '';

      if (email == savedEmail && savedEmail.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Email tersebut sudah digunakan oleh sistem!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      // ------------------------------------

      final provider = context.read<UserProvider>();
      final updatedUser = provider.user.copyWith(
        name: name,
        email: email,
        isLoggedIn: true,
      );

      provider.updateUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<UserProvider>().logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (provider.user.isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 16),
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.deepPurple,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),

                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nama',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                              if (!emailRegex.hasMatch(value.trim())) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          ElevatedButton.icon(
                            onPressed: _saveProfile,
                            icon: const Icon(Icons.save),
                            label: const Text('Simpan Profil'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- UI Latihan 3: Daftar Favorit ---
                    const Divider(thickness: 2),
                    const Text(
                      'Daftar Hobi / Favorit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _favController,
                            decoration: const InputDecoration(
                              hintText: 'Tambah hobi baru...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addFavorite,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Tambah'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _favorites.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            title: Text(_favorites[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeFavorite(index),
                            ),
                          ),
                        );
                      },
                    ),
                    // ------------------------------------

                    const SizedBox(height: 24),
                    Card(
                      color: Colors.amber[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info, color: Colors.amber[800]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Catatan Keamanan',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Data disimpan di SharedPreferences (plaintext).\n'
                              'Jangan simpan password atau data sensitif di sini.\n'
                              'Gunakan secure storage untuk data sensitif.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
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
