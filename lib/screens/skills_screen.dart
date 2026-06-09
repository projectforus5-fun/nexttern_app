import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SkillsScreen extends StatefulWidget {
  const SkillsScreen({super.key});

  @override
  State<SkillsScreen> createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  bool _isLoading = true;
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _fetchSkills();
  }

  // Mesin penyedot data keahlian dari database
  Future<void> _fetchSkills() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('skills')
            .eq('id', user.id)
            .maybeSingle();

        if (mounted) {
          setState(() {
            final String rawSkills = (data != null) ? (data['skills'] ?? '') : '';
            if (rawSkills.isNotEmpty) {
              // Memisahkan teks berdasarkan koma dan membersihkan spasi berlebih
              _skills = rawSkills.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
            }
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
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
        title: Text('Skill Saya', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4A44F2)))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Keahlian Utama',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Berikut adalah amunisi kamu yang akan dilirik oleh perusahaan saat melamar.',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 32),

            // Jika kosong, tampilkan pesan. Jika ada, tampilkan deretan Chip
            _skills.isEmpty
                ? Center(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.layers_clear_outlined, size: 80, color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Belum ada keahlian', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  Text('Silakan tambahkan skill kamu di menu Edit Profil.', style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey)),
                ],
              ),
            )
                : Wrap(
              spacing: 12, // Jarak antar kotak ke samping
              runSpacing: 12, // Jarak antar kotak ke bawah
              children: _skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A44F2).withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF4A44F2).withAlpha(75)),
                  ),
                  child: Text(
                    skill,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF4A44F2)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}