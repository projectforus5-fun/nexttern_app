import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'cv_screen.dart';
import 'skills_screen.dart';
import 'settings_screen.dart';
import 'home_screen.dart';
import 'main_screen.dart';
import 'search_screen.dart';
import 'bookmark_screen.dart';
import '../widgets/glass_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfileData();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _getProfileData();
    });
  }

  // Fungsi mengambil data dari Supabase (Tabel: profiles)
  Future<Map<String, dynamic>> _getProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('Belum login');

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      
      String? fullName = data?['full_name'];
      if (fullName == null || fullName.isEmpty) {
        fullName = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'User Nexttern';
      }

      String? avatarUrl = data?['avatar_url'];
      if (avatarUrl == null || avatarUrl.isEmpty) {
        avatarUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
      }

      return {
        'full_name': fullName,
        'avatar_url': avatarUrl,
        'role': (data?['role'] != null && data!['role'].toString().isNotEmpty) ? data['role'] : 'Mahasiswa',
        'university': (data?['university'] != null && data!['university'].toString().isNotEmpty) ? data['university'] : 'Universitas M.H Thamrin',
        'major': (data?['major'] != null && data!['major'].toString().isNotEmpty) ? data['major'] : 'Manajemen Informatika',
        'semester': (data?['semester'] != null && data!['semester'].toString().isNotEmpty) ? data['semester'] : 'Semester Baru',
      };
    } catch (e) {
      // Fallback total jika terjadi error network dll
      return {
        'full_name': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? 'User Nexttern',
        'avatar_url': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
        'role': 'Mahasiswa',
        'university': 'Universitas M.H Thamrin',
        'major': 'Manajemen Informatika',
        'semester': 'Semester 6',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    // JIKA USER BELUM LOGIN (GUEST MODE)
    if (user == null) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_outlined, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                const SizedBox(height: 16),
                Text('Belum Masuk', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 8),
                Text(
                  'Silakan masuk atau daftar akun untuk melihat profil dan riwayat lamaran Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 15),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A44F2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
        // Menu bawah tetap ditampilkan agar user tidak terjebak
      );
    }

    // JIKA SUDAH LOGIN, TAMPILKAN KODE PROFIL YANG SEBELUMNYA
    return Scaffold(
      backgroundColor: const Color(0xFF4A44F2),
      extendBody: true,
// ... (lanjutan kode Stack dan FutureBuilder Tuan Muda yang sebelumnya ada di sini)
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }

          final profile = snapshot.data ?? {};
          final fullName = profile['full_name'] ?? 'User Nexttern';
          final role = profile['role'] ?? 'Mahasiswa';
          final university = profile['university'] ?? 'Belum diatur';
          final majorAndSemester = '${profile['major'] ?? 'Jurusan'} • ${profile['semester'] ?? 'Semester'}';
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Stack(
            children: [
              // --- BAGIAN 1: HEADER UNGU (Atas) ---
              Positioned(
                top: 0, left: 0, right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            // Kembali ke MainScreen (Tab Home)
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const MainScreen()),
                                  (route) => false,
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),

              // --- BAGIAN 2: KONTEN PUTIH/HITAM MELENGKUNG (Bawah) ---
              Positioned(
                top: 140, // Titik mulai warna putih (memberi ruang untuk ungu di atas)
                left: 0, right: 0, bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF121212) : Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), // Ujung melengkung
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 70, bottom: 20), // Spasi agar teks tidak tertabrak foto
                    child: Column(
                      children: [
                        // Nama & Role
                        Text(fullName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 6),
                        Text(role, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade800, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 16),

                        // Kampus & Jurusan
                        Text(university, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text(majorAndSemester, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500)),
                        const SizedBox(height: 30),

                        // Statistik
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(context, '25', 'Lamaran'),
                            _buildStatItem(context, '3', 'Disimpan'),
                            _buildStatItem(context, '2', 'Diterima'),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Menu List
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              children: [
                                _buildMenuRow(
                                  context,
                                  Icons.edit_outlined,
                                  'Edit Profil',
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                                    );

                                    if (result == true) {
                                      _refreshProfile();
                                    }
                                  },
                                ),
                                _buildMenuRow(
                                  context,
                                  Icons.description_outlined,
                                  'CV Saya',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CVScreen()),
                                    );
                                  },
                                ),
                                _buildMenuRow(
                                  context,
                                  Icons.layers_outlined,
                                  'Skill Saya',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SkillsScreen()),
                                    );
                                  },
                                ),
                                _buildMenuRow(
                                  context,
                                  Icons.settings_outlined,
                                  'Pengaturan',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                    );
                                  },
                                ),
                                _buildMenuRow(context, Icons.shield_outlined, 'Bantuan'),

                                // Tombol Keluar
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.onSurface),
                                  title: Text('Keluar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
                                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                  onTap: () async {
                                    await Supabase.instance.client.auth.signOut();
                                    if (context.mounted) {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                                            (route) => false, // Menghapus semua history halaman
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- BAGIAN 3: FOTO PROFIL MENGAMBANG (Overlap) ---
              Positioned(
                top: 80, // Posisinya pas di garis batas ungu dan putih
                left: 0, right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(4), // Membuat efek border putih di sekeliling foto
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF121212) : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 50, // Ukuran foto besar
                      backgroundColor: Colors.grey.shade200,
                      // Menggunakan foto dari Google jika tersedia
                      backgroundImage: (profile['avatar_url'] != null && profile['avatar_url'].toString().isNotEmpty)
                          ? NetworkImage(profile['avatar_url'])
                          : const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Fungsi kecil pembuat angka statistik
  Widget _buildStatItem(BuildContext context, String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildMenuRow(BuildContext context, IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell( // InkWell memberikan efek sentuhan
      onTap: onTap ?? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fitur $title akan segera hadir!')),
        );
      }, // Menjalankan perintah saat diklik
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.onSurface),
            const SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
