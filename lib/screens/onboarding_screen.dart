import 'package:flutter/material.dart';
import 'main_screen.dart'; // Ubah ini

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Pengatur halaman untuk mengontrol geseran slide
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Data konten untuk 3 slide onboarding (Tuan Muda bisa ubah teks & gambarnya di sini)
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'Temukan Magang\nImpianmu',
      'subtitle': 'Ribuan peluang magang dari perusahaan terbaik menantimu untuk dijelajahi.',
      'image': 'https://img.freepik.com/free-vector/work-time-concept-illustration_114360-1474.jpg',
    },
    {
      'title': 'Perusahaan\nTerverifikasi',
      'subtitle': 'Kami memastikan semua lowongan berasal dari mitra perusahaan yang terpercaya.',
      'image': 'https://img.freepik.com/free-vector/business-deal-concept-illustration_114360-3942.jpg',
    },
    {
      'title': 'Mulai Karir\nProfesionalmu',
      'subtitle': 'Siapkan CV terbaikmu dan mulailah langkah pertama menuju masa depan cerah.',
      'image': 'https://img.freepik.com/free-vector/launching-concept-illustration_114360-2646.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER: TOMBOL LEWATI ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // Tombol Lewati langsung ke MainScreen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                    );
                  },
                  child: Text(
                    'Lewati',
                    style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 16),
                  ),
                ),
              ),
            ),

            // --- BODY: PAGEVIEW (GESER SLIDE) ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index; // Update titik indikator saat digeser
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Judul
                        Text(
                          _onboardingData[index]['title']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subjudul
                        Text(
                          _onboardingData[index]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5),
                        ),
                        const Spacer(),
                        // Gambar Ilustrasi
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F2FF),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Image.network(
                              _onboardingData[index]['image']!,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator(value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null));
                              },
                              errorBuilder: (context, error, stackTrace) => Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- FOOTER: INDIKATOR & TOMBOL ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Indikator Titik (Dot)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                          (index) => _buildDot(isActive: _currentIndex == index),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Dinamis
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A44F2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (_currentIndex == _onboardingData.length - 1) {
                          // Jika sudah di slide terakhir, masuk ke MainScreen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MainScreen()),
                          );
                        } else {
                          // Jika belum terakhir, lanjut ke slide berikutnya
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == _onboardingData.length - 1
                            ? 'Mulai Sekarang' // Teks di slide terakhir
                            : 'Selanjutnya',   // Teks di slide 1 & 2
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembuat titik indikator
  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A44F2) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}