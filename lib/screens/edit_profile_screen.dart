import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/notification_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _univController = TextEditingController();
  final _majorController = TextEditingController();
  final _semesterController = TextEditingController();
  final _roleController = TextEditingController();
  final _skillsController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  // Load data profil yang sudah ada
  Future<void> _loadCurrentProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        setState(() {
          _nameController.text = data['full_name'] ?? '';
          _univController.text = data['university'] ?? '';
          _majorController.text = data['major'] ?? '';
          _semesterController.text = data['semester'] ?? '';
          _roleController.text = data['role'] ?? '';
          _skillsController.text = data['skills'] ?? '';
          _currentImageUrl = data['avatar_url'];
        });
      } else {
        // Jika data profile belum ada di tabel, ambil default dari metadata Google
        setState(() {
          _nameController.text = user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? '';
          _roleController.text = 'Mahasiswa';
          _currentImageUrl = user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'];
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  // Fungsi Pilih Foto
  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _selectedImage = File(result.files.single.path!);
      });
    }
  }

  // --- MESIN PENYIMPAN DATA & FOTO ---
  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        String? imageUrl = _currentImageUrl;

        // Jika ada foto baru dipilih, upload dulu
        if (_selectedImage != null) {
          final fileName = 'Avatar_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
          await Supabase.instance.client.storage
              .from('cv_uploads') // Gunakan bucket yang sudah ada atau ganti jika perlu
              .upload(fileName, _selectedImage!);
          
          imageUrl = Supabase.instance.client.storage
              .from('cv_uploads')
              .getPublicUrl(fileName);
        }

        // Update atau Insert data ke tabel profiles (UPSERT)
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'full_name': _nameController.text,
          'university': _univController.text,
          'major': _majorController.text,
          'semester': _semesterController.text,
          'skills': _skillsController.text,
          'avatar_url': imageUrl,
          'updated_at': DateTime.now().toIso8601String(),
        });

        if (mounted) {
          // Trigger Notifikasi!
          NotificationService.showNotification(
            title: 'Profil Diperbarui! ✨',
            body: 'Perubahan datamu sudah berhasil disimpan dengan aman.',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil diperbarui! 🚀'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _univController.dispose();
    _majorController.dispose();
    _semesterController.dispose();
    _roleController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Lengkapi Biodata', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN FOTO ---
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      image: _selectedImage != null
                          ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                          : (_currentImageUrl != null
                              ? DecorationImage(image: NetworkImage(_currentImageUrl!), fit: BoxFit.cover)
                              : null),
                    ),
                    child: (_selectedImage == null && _currentImageUrl == null)
                        ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Color(0xFF4A44F2), shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Mari lengkapi profil kamu agar perusahaan lebih mudah melirik lamaran yang dikirimkan!', style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey)),
            const SizedBox(height: 24),

            // 1. Form Nama Lengkap
            _buildTextField(context, 'Nama Lengkap', 'Contoh: Nama Lengkap Anda', _nameController),
            const SizedBox(height: 16),

            // 2. Form Kampus
            _buildTextField(context, 'Asal Kampus / Sekolah', 'Contoh: Nama Universitas (Masukan Nama Universitas Anda)', _univController),
            const SizedBox(height: 16),

            // 3. Form Program Studi
            _buildTextField(context, 'Program Studi', 'Contoh: Program Studi Anda Saat Ini', _majorController),
            const SizedBox(height: 16),

            // 4. Form Semester
            _buildTextField(context, 'Semester', 'Contoh: Semester 6', _semesterController),
            const SizedBox(height: 16),

            // 5. Form Peran / Status
            _buildTextField(context, 'Status (Role)', 'Contoh: Mahasiswa / Alumni', _roleController),
            const SizedBox(height: 16),

            // 6. Form Keahlian
            _buildTextField(context, 'Keahlian Utama (Pisahkan dengan koma)', 'Contoh: Flutter, Dart, Figma', _skillsController),
            const SizedBox(height: 40),

            // --- TOMBOL SIMPAN ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A44F2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text('Simpan Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget custom agar form terlihat seragam dan rapi
  Widget _buildTextField(BuildContext context, String label, String hint, TextEditingController controller) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F2FF),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}