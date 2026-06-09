import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'main_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Mohon isi email dan kata sandi Anda.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Kredensial tidak valid. Silakan coba lagi.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // Ganti dengan Web Client ID dari Google Cloud Console kamu
      const webClientId = '624967564367-jr7e7b80ihfr2heu066onmurujkglbra.apps.googleusercontent.com';

      final googleSignIn = GoogleSignIn(
        serverClientId: webClientId,
      );
      final googleUser = await googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final accessToken = googleAuth?.accessToken;
      final idToken = googleAuth?.idToken;

      if (idToken == null || accessToken == null) {
        throw 'Gagal mendapatkan token dari Google.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal masuk dengan Google: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : const Color(0xFF4A44F2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            // Kembali ke MainScreen agar menu bawah muncul
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
                  (route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Logo atau Ikon Aplikasi
              Container(
                height: 50, width: 50,
                decoration: BoxDecoration(color: const Color(0xFF4A44F2), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.work_outline, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 24),
              Text('Masuk ke Akun Anda', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('Selamat datang kembali di Nexttern. Silakan masukkan kredensial Anda untuk melanjutkan.', style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5)),
              const SizedBox(height: 40),

              // Form Email
              _buildTextField(
                context,
                controller: _emailController,
                label: 'Alamat Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Form Password
              _buildTextField(
                context,
                controller: _passwordController,
                label: 'Kata Sandi',
                icon: Icons.lock_outline,
                isPassword: true,
                obscureText: _obscureText,
                onToggleVisibility: () => setState(() => _obscureText = !_obscureText),
              ),

              // Lupa Kata Sandi
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen())),
                  child: const Text('Lupa Kata Sandi?', style: TextStyle(color: Color(0xFF4A44F2), fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Login
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A44F2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),

              // Divider Opsi Lain
              Row(
                children: [
                  Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Atau masuk dengan', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Social Login
              Row(
                children: [
                  Expanded(
                    child: _buildSocialBtn(
                      context,
                      'Google',
                      Icons.g_mobiledata_rounded,
                      onPressed: _isLoading ? null : _handleGoogleSignIn,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialBtn(
                      context,
                      'Apple',
                      Icons.apple,
                      onPressed: () {
                        _showSnackBar('Login dengan Apple akan segera hadir!');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Navigasi ke Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum memiliki akun?', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
                    child: const Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A44F2))),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Desain Input Field Super Elegan
  Widget _buildTextField(BuildContext context, {required TextEditingController controller, required String label, required IconData icon, bool isPassword = false, bool obscureText = false, VoidCallback? onToggleVisibility, TextInputType keyboardType = TextInputType.text}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
        suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade400, size: 22), onPressed: onToggleVisibility) : null,
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF4A44F2), width: 1.5)),
      ),
    );
  }

  // Desain Tombol Social Login
  Widget _buildSocialBtn(BuildContext context, String text, IconData icon, {VoidCallback? onPressed}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, color: Theme.of(context).colorScheme.onSurface, size: 24),
      label: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w600)),
    );
  }
}