import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class PairingPage extends StatefulWidget {
  const PairingPage({super.key});
  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage>
    with SingleTickerProviderStateMixin {
  String? _code;
  String? _expiresIn;
  bool _loading = false;
  String? _error;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.97, end: 1.03).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateCode() async {
    setState(() {
      _loading = true;
      _error = null;
      _code = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final res = await http.post(
        Uri.parse(
            '${AppConstants.serverUrl}${AppConstants.generateCodeEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200) {
        setState(() {
          _code = data['code'];
          _expiresIn = data['expires_in'];
        });
      } else {
        setState(() => _error = data['error'] ?? 'Failed to generate code');
      }
    } catch (_) {
      setState(() => _error = 'Cannot reach server');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _copyCode() {
    if (_code == null) return;
    Clipboard.setData(ClipboardData(text: _code!));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Code copied to clipboard!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pair with Child',
            style: TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.primary.withOpacity(0.35),
                      blurRadius: 24,
                      spreadRadius: 4)
                ],
              ),
              child: const Icon(Icons.link_rounded,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Generate Pairing Code',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Generate a 6-digit code and share it with your child\'s Flamingo app to connect',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Code display
            if (_code != null) ...[
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) =>
                    Transform.scale(scale: _pulse.value, child: child),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 28, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: AppTheme.primary.withOpacity(0.3), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: AppTheme.primary.withOpacity(0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        _code!,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 12,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.timer_outlined,
                              color: AppTheme.textSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Expires in $_expiresIn',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _copyCode,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.copy_rounded,
                                  color: AppTheme.primary, size: 18),
                              SizedBox(width: 8),
                              Text('Copy Code',
                                  style: TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.error_outline,
                      color: AppTheme.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(_error!,
                          style: const TextStyle(color: AppTheme.error))),
                ]),
              ),
              const SizedBox(height: 16),
            ],

            // Generate button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6))
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _generateCode,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16))),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          _code != null
                              ? 'Generate New Code'
                              : 'Generate Code',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Steps
            _buildStep('1', 'Tap "Generate Code" above',
                Icons.touch_app_rounded),
            const SizedBox(height: 12),
            _buildStep('2', 'Share the 6-digit code with your child',
                Icons.share_rounded),
            const SizedBox(height: 12),
            _buildStep('3',
                'Child enters the code in their Flamingo app to connect',
                Icons.link_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
              child: Text(text,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 13,
                      height: 1.4))),
          Icon(icon, color: AppTheme.primary.withOpacity(0.5), size: 20),
        ],
      ),
    );
  }
}
