import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Tambahkan ini
import '../main.dart'; // Import notifier tema

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationEnabled = true;
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- MESIN COKOR SUPABASE UNTUK UBAH PASSWORD ---
  Future<void> _changePassword() async {
    if (_passwordController.text.trim().length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal harus 6 karakter!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Memperbarui password user yang sedang aktif langsung ke auth Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );

      _passwordController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil diperbarui! 🔐'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengubah password: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Pengaturan', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // --- BAGIAN 1: INFO AKUN ---
            const Text('Akun Terhubung', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A44F2))),
        const SizedBox(height: 12),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.onSurface),
          title: const Text('Email Akun', style: TextStyle(fontSize: 14, color: Colors.grey)),
          subtitle: Text(user?.email ?? '-', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
        ),
        const Divider(),
        const SizedBox(height: 16),

        // --- BAGIAN 2: PREFERENSI ---
        const Text('Preferensi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A44F2))),
        const SizedBox(height: 12),
        
        // --- TOGGLE DARK MODE ---
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: Icon(themeNotifier.value == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode, color: const Color(0xFF4A44F2)),
          title: const Text('Mode Gelap', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          subtitle: const Text('Ubah tampilan aplikasi menjadi gelap'),
          value: themeNotifier.value == ThemeMode.dark,
          activeColor: const Color(0xFF4A44F2),
          onChanged: (bool value) async {
            setState(() {
              themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
            });
            // Simpan pilihan user ke memori HP
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDarkMode', value);
          },
        ),

        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF4A44F2)),
          title: const Text('Notifikasi Magang Baru', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
          subtitle: const Text('Dapatkan info instan saat ada lowongan baru'),
          value: _isNotificationEnabled,
          activeColor: const Color(0xFF4A44F2),
          onChanged: (value) {
            setState(() {
              _isNotificationEnabled = value;
            });
          },
        ),
        const Divider(),
        const SizedBox(height: 16),

        // --- BAGIAN 3: KEAMANAN (UBAH PASSWORD) ---
        const Text('Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A44F2))),
        const SizedBox(height: 16),
        const Text('Ubah Password Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: 'Masukkan password baru kamu...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: const Color(0xFFF3F2FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A44F2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : _changePassword,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Perbarui Password', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15)),
          ),
        ),
      ],
    ),
    ),
    );
  }
}