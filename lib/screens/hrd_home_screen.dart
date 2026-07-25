import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class HrdHomeScreen extends StatefulWidget {
  const HrdHomeScreen({super.key});

  @override
  State<HrdHomeScreen> createState() => _HrdHomeScreenState();
}

class _HrdHomeScreenState extends State<HrdHomeScreen> {
  bool _isLoading = true;
  List<dynamic> _applicants = [];

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants() async {
    setState(() => _isLoading = true);
    try {
      final data = await Supabase.instance.client
          .from('applications')
          .select('*, profiles(full_name, university, email), jobs(title)')
          .order('created_at', ascending: false);

      setState(() {
        _applicants = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Dashboard Perusahaan', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: _handleLogout, icon: const Icon(Icons.logout_rounded, color: Colors.redAccent)),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchApplicants,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  const Text('Pelamar Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_applicants.isEmpty)
                    _buildEmptyState()
                  else
                    ..._applicants.map((app) => _buildApplicantCard(app, isDark)).toList(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Post Lowongan Baru'),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF4A44F2),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        _buildStatCard('Total Pelamar', _applicants.length.toString(), Colors.blue),
        const SizedBox(width: 12),
        _buildStatCard('Pending', _applicants.where((a) => a['status'] == 'Pending').length.toString(), Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(count, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicantCard(dynamic app, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: const Color(0xFF4A44F2).withOpacity(0.1), child: const Icon(Icons.person, color: Color(0xFF4A44F2))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app['profiles']['full_name'] ?? 'Kandidat', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(app['profiles']['university'] ?? 'Mahasiswa', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                _buildStatusChip(app['status']),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.work_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Posisi: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                Text(app['jobs']['title'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status ?? 'Pending', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('Belum ada lamaran masuk', style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
