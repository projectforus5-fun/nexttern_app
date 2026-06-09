import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_screen.dart'; // Pastikan rute ini benar
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkRoute();
  }

  Future<void> _checkRoute() async {
    await Future.delayed(const Duration(seconds: 2)); // Waktu pamer logo
    if (!mounted) return;

    // 1. Cek apakah ada sesi login (User sudah masuk)
    final session = Supabase.instance.client.auth.currentSession;

    if (!mounted) return;

    if (session != null) {
      // Skenario A: Sudah Login -> Langsung ke MainScreen (Beranda)
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
      return;
    }

    // 2. Jika belum login, cek memori SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (hasSeenOnboarding) {
      // Skenario B: Belum login, tapi DULU sudah pernah lihat onboarding -> Langsung ke Login
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      // Skenario C: Benar-benar PENGGUNA BARU -> Tampilkan Onboarding
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF), // Warna utama aplikasi Tuan
      body: Center(
        // Ganti dengan Logo Aplikasi Tuan Muda
        child: Image.asset('assets/images/logo.png', width: 200),
      ),
    );
  }
}