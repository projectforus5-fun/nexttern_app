import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';
import '../widgets/glass_nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final String? searchQuery;
  final String? workType;
  final bool? onlyPaid;

  const MainScreen({
    super.key, 
    this.initialIndex = 0, 
    this.searchQuery,
    this.workType,
    this.onlyPaid,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  String? _pendingQuery;
  String? _pendingType;
  bool? _pendingPaid;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pendingQuery = widget.searchQuery;
    _pendingType = widget.workType;
    _pendingPaid = widget.onlyPaid;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const HomeScreen(),
      SearchScreen(
        key: ValueKey('${_pendingQuery}_${_pendingType}_${_pendingPaid}'),
        initialQuery: _pendingQuery,
        initialType: _pendingType,
        initialPaid: _pendingPaid,
      ),
      const BookmarkScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        // Kita gunakan Key yang berbeda jika ada query baru agar SearchScreen meriset state-nya
        children: screens.asMap().entries.map((entry) {
          if (entry.key == 1 && _pendingQuery != null) {
             // Jika sedang di tab search dan ada query, kita paksa rebuild dengan Key unik
             return SearchScreen(key: ValueKey(_pendingQuery), initialQuery: _pendingQuery);
          }
          return entry.value;
        }).toList(),
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index != 1) {
              _pendingQuery = null; // Riset query jika pindah dari tab cari
            }
          });
        },
      ),
    );
  }
}
