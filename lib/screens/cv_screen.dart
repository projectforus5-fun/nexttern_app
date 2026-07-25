import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CVScreen extends StatefulWidget {
  const CVScreen({super.key});

  @override
  State<CVScreen> createState() => _CVScreenState();
}

class _CVScreenState extends State<CVScreen> {
  bool _isLoading = false;
  String? _currentCvUrl;
  String _userName = 'Pejuang';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Mengambil data CV dan Nama dari tabel profiles
  Future<void> _fetchUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final data = await Supabase.instance.client
          .from('profiles')
          .select('cv_url, full_name')
          .eq('id', user.id)
          .maybeSingle();

      if (mounted && data != null) {
        setState(() {
          _currentCvUrl = data['cv_url'];
          final fullName = data['full_name'] as String?;
          if (fullName != null && fullName.isNotEmpty) {
            _userName = fullName.split(' ')[0]; // Ambil nama depan
          }
        });
      }
    }
  }

  // Mesin Upload CV (Mirip dengan yang ada di Job Detail)
  Future<void> _uploadCV() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final file = File(result.files.single.path!);
      final fileName = 'Profil_${DateTime.now().millisecondsSinceEpoch}_${user.email}.pdf';

      // Menggunakan bucket 'cv_uploads' milik Tuan
      await Supabase.instance.client.storage
          .from('cv_uploads')
          .upload(fileName, file);

      final String cvUrl = Supabase.instance.client.storage
          .from('cv_uploads')
          .getPublicUrl(fileName);

      // Simpan link-nya ke tabel profiles (UPSERT agar aman bagi user baru)
      await Supabase.instance.client.from('profiles').upsert({
        'id': user.id,
        'cv_url': cvUrl,
        'updated_at': DateTime.now().toIso8601String(),
      });

      setState(() {
        _currentCvUrl = cvUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('CV Utama berhasil diperbarui! 🚀'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('Kelola CV', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.picture_as_pdf, size: 100, color: _currentCvUrl != null ? const Color(0xFF4A44F2) : (isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
            const SizedBox(height: 24),

            Text(
              _currentCvUrl != null ? 'CV anda sudah tersimpan di sistem!' : 'Belum ada CV yang diunggah',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              _currentCvUrl != null
                  ? 'CV ini akan digunakan sebagai referensi utama saat $_userName melamar magang.'
                  : 'Unggah CV terbaik $_userName dalam format PDF agar perusahaan bisa melihat potensi $_userName.',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentCvUrl != null ? (isDark ? const Color(0xFF1E1E1E) : Colors.white) : const Color(0xFF4A44F2),
                  side: _currentCvUrl != null ? const BorderSide(color: Color(0xFF4A44F2), width: 2) : BorderSide.none,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _isLoading ? null : _uploadCV,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Color(0xFF4A44F2))
                    : Text(
                    _currentCvUrl != null ? 'Ganti CV' : 'Unggah CV',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _currentCvUrl != null ? const Color(0xFF4A44F2) : Colors.white
                    )
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}