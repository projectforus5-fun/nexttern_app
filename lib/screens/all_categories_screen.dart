import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main_screen.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  // Fungsi untuk menentukan ikon (sama seperti yang di Home)
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        title: Text('Semua Kategori', style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder(
        // 1. Langsung tarik dari tabel sumber utamanya!
        future: Supabase.instance.client.from('categories').select('name'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF4A44F2)));
          }

          final categories = snapshot.data as List? ?? [];
          if (categories.isEmpty) return Center(child: Text('Belum ada kategori tersedia.', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)));

          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              // 2. Langsung ambil 'name' dari tabel categories
              final catName = categories[index]['name'].toString();
              return GestureDetector(
                onTap: () {
                  // Navigasi ke MainScreen (Tab Search) dengan query terpilih
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen(initialIndex: 1, searchQuery: catName)),
                    (route) => false,
                  );
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F2FF), 
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Icon(_getCategoryIcon(catName), color: const Color(0xFF4A44F2), size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      catName, 
                      textAlign: TextAlign.center, 
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), 
                      maxLines: 2, 
                      overflow: TextOverflow.ellipsis
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
