import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import '../widgets/job_card.dart'; // Memanggil desain kotak lowongan
import '../widgets/job_shimmer.dart'; // Import ini

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key, 
    this.initialQuery, 
    this.initialType, 
    this.initialPaid
  });
  
  final String? initialQuery;
  final String? initialType;
  final bool? initialPaid;


  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Variabel untuk menyimpan teks pencarian dan filter aktif
  late TextEditingController _searchController;
  String _searchQuery = '';
  
  // Filter State
  String _selectedType = 'Semua'; // WFH, WFO, Hybrid
  bool _onlyPaid = false;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Jika halaman ini dikirimi data dari Home, gunakan itu
    _searchQuery = widget.initialQuery ?? '';
    _selectedType = widget.initialType ?? 'Semua';
    _onlyPaid = widget.initialPaid ?? false;

    _searchController = TextEditingController(text: _searchQuery);
  }

  // --- FUNGSI UNTUK MEMBUKA MENU FILTER (BOTTOM SHEET) ---
  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder( // Agar UI di dalam bottom sheet bisa update saat diklik
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
                  const Text('Penyaringan Lanjutan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  // 1. Tipe Kerja
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

                  // 2. Status Gaji
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tampilkan Hanya Paid (Dibayar)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Switch(
                        value: _onlyPaid,
                        activeColor: const Color(0xFF4A44F2),
                        onChanged: (val) => setModalState(() => _onlyPaid = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tombol Terapkan
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
                        setState(() {}); // Rebuild list pencarian dengan filter baru
                        Navigator.pop(context);
                      },
                      child: const Text('Terapkan Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tombol Reset
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedType = 'Semua';
                          _onlyPaid = false;
                        });
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text('Atur Ulang (Reset)', style: TextStyle(color: Colors.red)),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
        title: Text('Eksplorasi Magang', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: Column(
        children: [
          // --- BAGIAN 1: KOTAK PENCARIAN & TOMBOL FILTER ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Cari posisi atau perusahaan...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? BorderSide(color: Colors.grey.shade800) : BorderSide.none),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: isDark ? BorderSide(color: Colors.grey.shade800) : BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // --- TOMBOL FILTER (IKON TUNE) ---
                GestureDetector(
                  onTap: _showFilterBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A44F2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ),

          // --- BAGIAN 2: STATUS FILTER AKTIF (Visual Info) ---
          if (_selectedType != 'Semua' || _onlyPaid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Filter: ${_selectedType != 'Semua' ? _selectedType : ''} ${_onlyPaid ? '• Paid Only' : ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // --- BAGIAN 3: DAFTAR LOWONGAN (DARI SUPABASE DENGAN FILTERING) ---
          Expanded(
            child: FutureBuilder(
              future: Supabase.instance.client.from('jobs').select('*, categories(*)'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    itemCount: 5,
                    itemBuilder: (_, __) => const JobShimmer(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
                }

                final allJobs = snapshot.data as List? ?? [];

                // --- MESIN PENYARINGAN UTAMA ---
                final filteredJobs = allJobs.where((job) {
                  final title = (job['title'] ?? '').toString().toLowerCase();
                  final company = (job['company'] ?? '').toString().toLowerCase();
                  final categoryMap = job['categories'] as Map<String, dynamic>?;
                  final categoryName = (categoryMap?['name'] ?? '').toString().toLowerCase();
                  final query = _searchQuery.toLowerCase();

                  // 1. Filter Teks
                  bool matchesSearch = query.isEmpty ||
                      title.contains(query) ||
                      company.contains(query) ||
                      categoryName.contains(query);

                  // 2. Filter Tipe Kerja (WFH/WFO/Hybrid)
                  bool matchesType = _selectedType == 'Semua' || (job['work_type'] ?? '').toString().toUpperCase() == _selectedType.toUpperCase();

                  // 3. Filter Gaji (Paid Only)
                  bool matchesSalary = !_onlyPaid || (job['is_paid'] == true || job['is_paid'] == 'true');

                  return matchesSearch && matchesType && matchesSalary;
                }).toList();

                if (filteredJobs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 80, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('Tidak ada hasil yang cocok.', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                        TextButton(
                          onPressed: () => setState(() {
                            _searchQuery = '';
                            _selectedType = 'Semua';
                            _onlyPaid = false;
                            _searchController.clear();
                          }),
                          child: const Text('Reset Semua Filter'),
                        )
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    return JobCard(job: filteredJobs[index] as Map<String, dynamic>);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
