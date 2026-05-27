import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../../core/utils/socket_service.dart';
import '../../../home/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() { _animCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final url = _isLogin
      ? '${AppConstants.serverUrl}${AppConstants.loginEndpoint}'
      : '${AppConstants.serverUrl}${AppConstants.registerEndpoint}';

    final body = _isLogin
      ? {'email': _emailCtrl.text.trim(), 'password': _passCtrl.text}
      : {'name': _nameCtrl.text.trim(), 'email': _emailCtrl.text.trim(), 'password': _passCtrl.text, 'role': 'parent'};

    try {
      final res = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final token = data['token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(data['user']));
        sl<SocketService>().connect(token);
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
      } else {
        setState(() => _error = data['error'] ?? 'Something went wrong');
      }
    } catch (_) {
      setState(() => _error = 'Cannot reach server. Check YOUR_SERVER_IP in constants.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Top branding
              Expanded(
                flex: 2,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🦩', style: TextStyle(fontSize: 64)),
                      const SizedBox(height: 12),
                      const Text('Flamingo', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      const Text('Parent App', style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              // Form card
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                  ),
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isLogin ? 'Welcome back 👋' : 'Create account', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        const SizedBox(height: 4),
                        Text(_isLogin ? 'Sign in to monitor your child' : 'Register as a parent', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                        const SizedBox(height: 24),
                        if (!_isLogin) ...[
                          _field(_nameCtrl, 'Your Name', Icons.person_outline),
                          const SizedBox(height: 14),
                        ],
                        _field(_emailCtrl, 'Email', Icons.email_outlined, type: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _field(_passCtrl, 'Password', Icons.lock_outline, obscure: true),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: AppTheme.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              const Icon(Icons.error_outline, color: AppTheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13))),
                            ]),
                          ),
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity, height: 54,
                          child: DecoratedBox(
                            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0,6))]),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                              child: _loading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                : Text(_isLogin ? 'Sign In' : 'Create Account', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() { _isLogin = !_isLogin; _error = null; }),
                            child: Text(_isLogin ? "Don't have an account? Register" : 'Already registered? Sign in', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label, IconData icon, {bool obscure = false, TextInputType? type}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure && _obscure,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
        suffixIcon: obscure ? IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20), onPressed: () => setState(() => _obscure = !_obscure)) : null,
        filled: true, fillColor: AppTheme.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        labelStyle: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }
}
