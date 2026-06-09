import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import '../widgets/job_card.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // --- GUEST MODE CHECK ---
    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBody: true,
        body: _buildGuestMode(context),
      );
    }

    // --- TAMPILAN JIKA SUDAH LOGIN ---
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('Aktivitas Saya', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 24)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A44F2),
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: const Color(0xFF4A44F2),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Disimpan'),
            Tab(text: 'Riwayat Lamaran'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: LOWONGAN DISIMPAN (Dinamis dari Database)
          FutureBuilder(
            // Mengambil dari tabel 'saved_jobs' berdasarkan 'user_email'
            future: Supabase.instance.client
                .from('saved_jobs')
                .select('*, jobs(*)') // Relasi join untuk mengambil detail pekerjaannya
                .eq('user_email', user!.email!), // Cocokkan dengan email yang login
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4A44F2)));
              }

              final savedJobs = snapshot.data as List? ?? [];

              if (savedJobs.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.bookmark_border_rounded,
                  title: 'Belum Ada yang Disimpan',
                  subtitle: 'Lowongan yang kamu tandai akan muncul di sini.',
                  buttonText: 'Cari Lowongan',
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SearchScreen())),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: savedJobs.length,
                itemBuilder: (context, index) {
                  // Karena kita pakai select('*, jobs(*)'), data lowongannya ada di dalam key 'jobs'
                  final jobData = savedJobs[index]['jobs'] as Map<String, dynamic>?;

                  // Jika karena suatu hal data jobs-nya null, jangan tampilkan error
                  if (jobData == null) return const SizedBox();

                  return JobCard(
                    job: jobData,
                    isSaved: true,
                    onChange: () {
                      // setState kosong ini akan memaksa FutureBuilder bekerja ulang
                      // sehingga lowongan yang baru saja dihapus akan langsung lenyap dari layar!
                      setState(() {});
                    },
                    // -----------------------------
                  );
                },
              );
            },
          ),

          // TAB 2: RIWAYAT LAMARAN
          // --- TAB 2: RIWAYAT LAMARAN ---
          FutureBuilder(
            // Menarik data lamaran milik user yang sedang login, lengkap dengan info pekerjaannya
            future: Supabase.instance.client
                .from('applications')
                .select('*, jobs(*)')
                .eq('applicant_email', Supabase.instance.client.auth.currentUser?.email ?? ''),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4A44F2)));
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
              }

              final applications = snapshot.data as List? ?? [];

              if (applications.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.send_time_extension_outlined,
                  title: 'Belum Ada Lamaran',
                  subtitle: 'Kamu belum mengirimkan lamaran apa pun. Yuk, mulai cari magang impian!',
                  buttonText: 'Cari Lowongan',
                  onPressed: () {
                    // Navigasi kembali ke home atau search
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  final job = app['jobs']; // Mengambil data lowongan hasil join

                  return _buildApplicationCard(
                    jobTitle: job['title'] ?? 'Posisi Tidak Diketahui',
                    company: job['company'] ?? 'Perusahaan Tidak Diketahui',
                    status: app['status'] ?? 'Pending',
                    date: app['created_at'] ?? '', // Nanti bisa diformat tanggalnya
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
  Widget _buildApplicationCard({required String jobTitle, required String company, required String status, required String date}) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'diterima': statusColor = Colors.green; break;
      case 'ditolak': statusColor = Colors.red; break;
      default: statusColor = Colors.orange; // Untuk 'Pending'
    }
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F2FF), 
              borderRadius: BorderRadius.circular(12)
            ),
            child: const Icon(Icons.business_center, color: Color(0xFF4A44F2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(jobTitle, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
                Text(company, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  // Desain Tampilan Kosong (Empty State) yang Profesional
  Widget _buildEmptyState({required IconData icon, required String title, required String subtitle, required String buttonText, required VoidCallback onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F2FF), shape: BoxShape.circle),
              child: Icon(icon, size: 60, color: const Color(0xFF4A44F2)),
            ),
            const SizedBox(height: 24),
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 14, height: 1.5)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A44F2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(200, 48),
                elevation: 0,
              ),
              onPressed: onPressed,
              child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Tampilan khusus untuk Guest Mode (Belum Login)
  Widget _buildGuestMode(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_person_outlined, size: 80, color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Akses Terbatas', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Masuk terlebih dahulu untuk menyimpan lowongan dan memantau status lamaran kamu.', textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 15)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A44F2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
