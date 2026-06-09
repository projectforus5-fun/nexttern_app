import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  bool _agreeToTerms = false; // Checkbox Syarat & Ketentuan

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      _showSnackBar('Anda harus menyetujui Syarat & Ketentuan untuk mendaftar.', isError: true);
      return;
    }
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Mohon lengkapi semua bidang.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // 1. Daftarkan User ke Auth Supabase
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'full_name': _nameController.text.trim()},
      );

      final String? userId = response.user?.id;

      // 2. JIKA pendaftaran berhasil, buatkan baris di tabel 'profiles' secara manual
      if (userId != null) {
        await Supabase.instance.client.from('profiles').upsert({
          'id': userId, // Hubungkan dengan ID dari tabel Auth
          'full_name': _nameController.text.trim(),
          'email': _emailController.text.trim(), // Pastikan kolom ini ada di tabel profiles Tuan
        });
      }

      if (mounted) {
        _showSnackBar('Pendaftaran berhasil! Silakan periksa email untuk verifikasi (jika aktif).');
        Navigator.pop(context); // Kembali ke halaman Login
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal mendaftar: $e', isError: true);
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Buat Akun Baru', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5, color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Mulai perjalanan karier profesional Anda dengan melengkapi data di bawah ini.', style: TextStyle(fontSize: 15, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, height: 1.5)),
            const SizedBox(height: 40),

            _buildTextField(context, controller: _nameController, label: 'Nama Lengkap Resmi', icon: Icons.person_outline),
            const SizedBox(height: 20),
            _buildTextField(context, controller: _emailController, label: 'Alamat Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 20),
            _buildTextField(
              context,
              controller: _passwordController, label: 'Kata Sandi (Minimal 8 karakter)', icon: Icons.lock_outline,
              isPassword: true, obscureText: _obscureText, onToggleVisibility: () => setState(() => _obscureText = !_obscureText),
            ),
            const SizedBox(height: 20),

            // Checkbox Syarat & Ketentuan (Khas aplikasi enterprise)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24, height: 24,
                  child: Checkbox(
                    value: _agreeToTerms,
                    activeColor: const Color(0xFF4A44F2),
                    checkColor: Colors.white,
                    side: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    onChanged: (val) => setState(() => _agreeToTerms = val!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      text: 'Saya menyetujui ', style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      children: const [
                        TextSpan(text: 'Syarat & Ketentuan ', style: TextStyle(color: Color(0xFF4A44F2), fontWeight: FontWeight.w600)),
                        TextSpan(text: 'serta '),
                        TextSpan(text: 'Kebijakan Privasi', style: TextStyle(color: Color(0xFF4A44F2), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A44F2), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Text('Daftar Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sudah memiliki akun?', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A44F2))),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

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
}