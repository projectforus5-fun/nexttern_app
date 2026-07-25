import 'dart:io'; // Tambahan untuk membaca file dari HP
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';


class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isLoading = false;

  // --- MESIN UTAMA PELAMARAN ---
  // --- MESIN UTAMA PELAMARAN & UPLOAD CV ---
  Future<void> _lamarPekerjaan() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamu harus masuk (Login) terlebih dahulu untuk melamar!'),
          backgroundColor: Color(0xFF4A44F2),
        ),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
      return;
    }

    // 1. MEMBUKA FILE MANAGER HP (Hanya izinkan file PDF)
    FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    // Jika Tuan Muda menekan tombol "Batal" / "Back" saat memilih file, hentikan proses
    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      // 2. CEK APAKAH SUDAH PERNAH MELAMAR
      final cekLamaran = await Supabase.instance.client
          .from('applications')
          .select()
          .eq('applicant_email', user.email!)
          .eq('job_id', widget.job['id']);

      if (cekLamaran.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kamu sudah melamar posisi ini sebelumnya!'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 3. PROSES UPLOAD CV KE SUPABASE STORAGE
      // Mengambil lokasi file yang dipilih dari HP
      final file = File(result.files.single.path!);

      // Membuat nama file yang unik (Contoh: 167890_email@gmail.com_CV.pdf)
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${user.email}_CV.pdf';

      // Mengunggah file ke bucket 'cv_bucket' di Supabase
      await Supabase.instance.client.storage
          .from('cv_uploads')
          .upload(fileName, file);

      // 4. MENGAMBIL LINK (URL) PUBLIK DARI CV YANG BARU DIUPLOAD
      final String cvUrl = Supabase.instance.client.storage
          .from('cv_uploads')
          .getPublicUrl(fileName);

      // 5. KIRIM DATA LAMARAN KE TABEL APPLICATIONS (Beserta URL CV Asli)
      await Supabase.instance.client.from('applications').insert({
        'job_id': widget.job['id'],
        'applicant_email': user.email,
        'status': 'Pending',
        'cv_url': cvUrl, // Link asli langsung tersimpan ke database!
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV Berhasil Diunggah & Lamaran Terkirim! 🚀'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya setelah sukses
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Karena sekarang StatefulWidget, panggil data dengan 'widget.job'
    bool isPaid = widget.job['is_paid'] == true || widget.job['is_paid'] == 'true';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur berbagi akan segera hadir!')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.job['company_logo'] != null && widget.job['company_logo'].toString().trim().isNotEmpty
                        ? Image.network(
                            widget.job['company_logo'].toString().trim(),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, color: Colors.grey, size: 30),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                            },
                          )
                        : const Icon(Icons.business, color: Colors.grey, size: 30),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.bookmark_border, size: 30, color: isDark ? Colors.grey.shade400 : Colors.grey),
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gunakan tombol bookmark di daftar lowongan!')),
                      );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              widget.job['title'] ?? 'Nama Posisi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              widget.job['company'] ?? 'Nama Perusahaan',
              style: const TextStyle(fontSize: 18, color: Color(0xFF4A44F2), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildTag(Icons.location_on_outlined, widget.job['location'] ?? 'Lokasi tidak diketahui'),
                _buildTag(Icons.work_outline, widget.job['work_type'] ?? 'Tipe kerja'),
                if (isPaid) _buildTag(Icons.monetization_on_outlined, 'Paid', isHighlight: true),
                _buildTag(Icons.school_outlined, 'Magang', isHighlight: true),
              ],
            ),
            const SizedBox(height: 30),

            Text(
              'Deskripsi Pekerjaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              widget.job['description'] ?? 'Belum ada deskripsi untuk lowongan ini.',
              style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, height: 1.6),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),

      // --- TOMBOL BAWAH ---
      bottomSheet: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: isDark ? Colors.grey.shade900 : Colors.grey.shade200)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A44F2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            // Tombol akan dimatikan (null) jika sedang loading agar tidak bisa dispam
            onPressed: _isLoading ? null : _lamarPekerjaan,
            child: _isLoading
                ? const SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
            )
                : const Text('Lamar Sekarang', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String text, {bool isHighlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF4A44F2).withOpacity(0.1) : (isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isHighlight ? const Color(0xFF4A44F2) : (isDark ? Colors.grey.shade400 : Colors.grey.shade700)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
              color: isHighlight ? const Color(0xFF4A44F2) : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }
}