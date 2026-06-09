import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/job_detail_screen.dart'; // Import halaman detail agar bisa dipanggil
import '../services/notification_service.dart'; // Import ini

class JobCard extends StatefulWidget {
  final Map<String, dynamic> job;
  final bool isSaved;
  final VoidCallback? onChange;

  const JobCard({super.key, required this.job, this.isSaved = false, this.onChange});

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {

  late bool _isSaved = false;
  @override
  void initState() {
    super.initState();
    _isSaved = widget.isSaved;
  }
  Widget build(BuildContext context) {
    // Mengecek apakah magang dibayar
    bool isPaid = widget.job['is_paid'] == true || widget.job['is_paid'] == 'true';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Membungkus Container dengan GestureDetector agar kotak bisa diklik
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail sambil membawa data 'job'
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailScreen(job: widget.job),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo Perusahaan
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                    image: widget.job['company_logo'] != null && widget.job['company_logo'].toString().isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(widget.job['company_logo']),
                      fit: BoxFit.contain,
                    )
                        : null,
                  ),
                  child: widget.job['company_logo'] == null || widget.job['company_logo'].toString().isEmpty
                      ? const Icon(Icons.business, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 16),

                // Info Pekerjaan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.job['title'] ?? 'Posisi Tidak Diketahui',
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.job['company'] ?? 'Perusahaan Rahasia',
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.job['location']} • ${widget.job['work_type']}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Ikon Bookmark
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                    icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, color: const Color(0xFF4A44F2),),
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan login dulu!')));
                      return;
                    }

                    try {
                      if (_isSaved) {
                        // --- JIKA SUDAH DISIMPAN: HAPUS DARI DATABASE ---
                        await Supabase.instance.client
                            .from('saved_jobs')
                            .delete()
                            .eq('user_email', user.email!)
                            .eq('job_id', widget.job['id']);

                        setState(() => _isSaved = false); // Ubah ikon kembali ke outline

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lowongan dihapus dari simpanan.')));
                        }
                      } else {
                        // --- JIKA BELUM DISIMPAN: MASUKKAN KE DATABASE ---
                        await Supabase.instance.client.from('saved_jobs').insert({
                          'user_email': user.email,
                          'job_id': widget.job['id'],
                        });

                        setState(() => _isSaved = true); // Ubah ikon menjadi penuh

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lowongan berhasil disimpan!'), backgroundColor: Colors.green));
                          
                          // Tampilkan notifikasi lokal
                          NotificationService.showNotification(
                            title: 'Berhasil Disimpan!',
                            body: 'Lowongan ${widget.job['title']} telah ditambahkan ke aktivitasmu.',
                          );
                        }
                      }

                      // Memanggil sinyal refresh ke halaman utama (jika ada)
                      if (widget.onChange != null) {
                        widget.onChange!();
                      }

                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Badges (Tag)
            Row(
              children: [
                if (isPaid) ...[
                  _buildBadge('Paid', isDark ? Colors.green.withOpacity(0.15) : Colors.green.shade50, isDark ? Colors.green.shade400 : Colors.green.shade700),
                  const SizedBox(width: 8),
                ],
                _buildBadge('Magang', isDark ? Colors.blue.withOpacity(0.15) : Colors.blue.shade50, isDark ? Colors.blue.shade400 : Colors.blue.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi pembuat badge agar rapi
  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}