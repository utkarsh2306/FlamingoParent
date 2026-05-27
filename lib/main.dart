import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/service_locator.dart';
import 'core/utils/socket_service.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const FlamingoParentApp());
}

class FlamingoParentApp extends StatelessWidget {
  const FlamingoParentApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flamingo Parent',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();
  @override State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _loading = true;
  bool _authed = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) sl<SocketService>().connect(token);
    setState(() { _authed = token != null; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return _authed ? const HomePage() : const LoginPage();
  }
}
