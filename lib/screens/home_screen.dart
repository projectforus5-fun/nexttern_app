import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart'; 
import '../widgets/job_card.dart';
import '../widgets/job_shimmer.dart';
import 'main_screen.dart';
import 'all_categories_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variabel untuk menyimpan teks pencarian dan filter aktif
  String _searchQuery = '';
  final user = Supabase.instance.client.auth.currentUser;

  // State Filter Sementara di Home
  String _selectedType = 'Semua';
  bool _onlyPaid = false;

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 24),
                  const Text('Penyaringan Cepat', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  const Text('Tipe Pekerjaan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ['Semua', 'WFH', 'WFO', 'Hybrid'].map((type) {
                      final isSelected = _selectedType == type;
                      return ChoiceChip(
                        label: Text(type),
                        selected: isSelected,
                        onSelected: (val) => setModalState(() => _selectedType = type),
                        selectedColor: const Color(0xFF4A44F2),
                        labelStyle: TextStyle(color: isSelected ? Colors.white : (isDark ? Colors.grey : Colors.black87)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Hanya Paid (Dibayar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Switch(
                        value: _onlyPaid,
                        activeColor: const Color(0xFF4A44F2),
                        onChanged: (val) => setModalState(() => _onlyPaid = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A44F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        // Terapkan dan pindah ke Tab Cari
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MainScreen(
                              initialIndex: 1, 
                              searchQuery: _searchQuery,
                              workType: _selectedType,
                              onlyPaid: _onlyPaid,
                            )
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text('Terapkan & Cari', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      },
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'manajemen informatika':
      case 'teknik informatika':
      case 'web dev':
        return Icons.laptop_mac;
      case 'desain':
      case 'ui/ux':
        return Icons.edit_outlined;
      case 'teknik kehewanan':
        return Icons.pets;
      case 'marketing':
        return Icons.campaign_outlined;
      case 'finance':
        return Icons.payments_outlined;
      default:
        return Icons.category_outlined;
    }
  }

  Widget _buildCategoryItem(
      {required IconData icon, required String label, required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFF4A44F2)),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true, // WAJIB: Agar background tembus ke bawah menu kaca
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- BAGIAN 1: HEADER (Sapaan & Ikon Lonceng) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                        future: Supabase.instance.client.auth.currentUser != null
                            ? Supabase.instance.client
                            .from('profiles')
                            .select('full_name')
                            .eq('id', Supabase.instance.client.auth.currentUser!.id)
                            .single()
                            : null,
                        builder: (context, snapshot) {
                          String namaPanggilan = 'Pejuang';

                          if (snapshot.hasData && snapshot.data != null) {
                            final data = snapshot.data as Map<String, dynamic>;
                            final String namaLengkap = data['full_name'] ?? 'Pejuang';

                            if (namaLengkap != 'Pejuang' && namaLengkap.isNotEmpty) {
                              // Mengambil kata pertama saja (sebelum spasi) untuk nama panggilan
                              namaPanggilan = namaLengkap.split(' ')[0];
                            }
                          }

                          return Text(
                            'Hi, $namaPanggilan 👋',
                            style: TextStyle(
                              fontSize: 20, // Menyesuaikan dengan ukuran font di gambar Tuan
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Siap cari pengalaman baru hari ini?',
                        style: TextStyle(
                            fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Belum ada notifikasi baru!')),
                      );
                    },
                    icon: Icon(
                        Icons.notifications_none_rounded, 
                        size: 28,
                        color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- BAGIAN 2: SEARCH BAR ---
              TextField(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value; // Mengupdate UI secara real-time
                  });
                },
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Cari posisi, perusahaan, atau skill',
                  hintStyle: TextStyle(
                      color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: GestureDetector(
                    onTap: _showFilterBottomSheet,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                          Icons.tune, color: Theme.of(context).colorScheme.onSurface, size: 20),
                    ),
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- BAGIAN 3: BANNER BIRU ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A44F2), // Warna utama aplikasi
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saatnya upgrade dirimu',
                            style: TextStyle(color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Temukan pengalaman yang\nmembentuk masa depanmu.',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF4A44F2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              minimumSize: const Size(120, 36),
                            ),
                            onPressed: () {
                              // Navigasi ke Tab Cari di MainScreen
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
                                (route) => false,
                              );
                            },
                            child: const Text('Cari Magang', style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    // Ilustrasi Roket Sementara
                    const Icon(
                        Icons.rocket_launch, color: Colors.white, size: 80),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- BAGIAN 4: KATEGORI POPULER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Kategori Populer', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  TextButton(
                    onPressed: () {
                      // ---> NAVIGASI KE HALAMAN SEMUA KATEGORI <---
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const AllCategoriesScreen()));
                    },
                    child: const Text('Lihat Semua', style: TextStyle(
                        color: Color(0xFF4A44F2), fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- KATEGORI TERPOPULER (DARI SQL VIEW) ---
              SizedBox(
                height: 100,
                child: FutureBuilder(
                  // Mengambil 4 juara teratas dari mesin SQL
                  future: Supabase.instance.client
                      .from('popular_categories').select('category_name').limit(4),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 4,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Shimmer.fromColors(
                            baseColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900]! : Colors.grey[300]!,
                            highlightColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[100]!,
                            child: Column(
                              children: [
                                Container(width: 55, height: 55, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
                                const SizedBox(height: 8),
                                Container(width: 50, height: 10, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                          child: Text('Gagal memuat', style: TextStyle(
                              fontSize: 12, color: Colors.red)));
                    }

                    final popularData = snapshot.data as List? ?? [];
                    if (popularData.isEmpty) {
                      return const Center(
                        child: Text('Belum ada kategori', style: TextStyle(
                            fontSize: 12)));
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: popularData.length,
                      itemBuilder: (context, index) {
                        final catName = popularData[index]['category_name'].toString();

                        // Memanggil widget pembuat kotak kategori
                        return _buildCategoryItem(
                          icon: _getCategoryIcon(catName),
                          label: catName,
                          onTap: () {
                            // Navigasi ke Tab Cari dengan query kategori
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 1, searchQuery: catName)),
                              (route) => false,
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              // --- BAGIAN 5: REKOMENDASI LOWONGAN (DARI SUPABASE) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Rekomendasi Untukmu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  TextButton(
                      onPressed: () {
                        // Navigasi ke Tab Cari
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen(initialIndex: 1)),
                          (route) => false,
                        );
                      },
                      child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF4A44F2), fontSize: 12))
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Mengambil data dari Supabase
              FutureBuilder(
                // ---> 1. UBAH QUERY: Tambahkan perintah Join '*, categories(*)' <---
                future: Supabase.instance.client.from('jobs').select('*, categories(*)'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 3,
                      itemBuilder: (context, index) => const JobShimmer(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
                  }

                  final allJobs = snapshot.data as List? ?? [];

                  // Proses penyaringan (Filtering) Real-time
                  final filteredJobs = allJobs.where((job) {
                    final title = (job['title'] ?? '').toString().toLowerCase();
                    final company = (job['company'] ?? '').toString().toLowerCase();

                    // ---> 2. AMBIL NAMA KATEGORI DARI HASIL JOIN <---
                    final categoryMap = job['categories'] as Map<String, dynamic>?;
                    final categoryName = (categoryMap?['name'] ?? '').toString().toLowerCase();

                    final query = _searchQuery.toLowerCase();

                    // ---> 3. TAMBAHKAN KATEGORI KE DALAM MESIN PENCARI <---
                    return title.contains(query) || company.contains(query) || categoryName.contains(query);
                  }).toList();

                  if (filteredJobs.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('Yah, lowongan tidak ditemukan.', style: TextStyle(color: Colors.grey)),
                      ),
                    );
                  }

                  // Tampilkan hasil filter ke dalam List
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final jobData = filteredJobs[index] as Map<String, dynamic>;
                      return JobCard(job: jobData);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
