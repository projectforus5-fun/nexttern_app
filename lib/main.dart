import 'package:flutter/material.dart';
import 'package:nexttern_app/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nexttern_app/services/notification_service.dart';

// Notifier global untuk mengatur mode gelap/terang di seluruh aplikasi
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Layanan Notifikasi
  await NotificationService.init();

  // Load preferensi tema sebelum aplikasi jalan
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  await Supabase.initialize(
    url: 'https://utoemobcomezpmuurgdf.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InV0b2Vtb2Jjb21lenBtdXVyZ2RmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg0MjI4NzEsImV4cCI6MjA5Mzk5ODg3MX0.r2J-5gpsv72x5pC7LsfpdlT0EOO9S7F4NBpw-6uO2SE',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nexttern App',
          themeMode: currentMode,
          
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A44F2),
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: Colors.white,
          ),
          
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4A44F2),
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),
          
          home: const SplashScreen(),
        );
      },
    );
  }
}
