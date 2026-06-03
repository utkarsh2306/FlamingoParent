import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../../core/utils/socket_service.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/pages/location_page.dart';
import '../../../sound_around/presentation/bloc/sound_around_bloc.dart';
import '../../../sound_around/presentation/pages/sound_around_page.dart';
import '../../../sos/presentation/pages/sos_alert_page.dart';
import '../pages/pairing_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _tab = 0;
  String _parentName = 'Parent';
  int? _childId;
  String? _childName;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadUser();
    _listenForSOS();
  }

  void _listenForSOS() {
    sl<SocketService>().on('sos:received', (data) {
      if (mounted) {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => SosAlertPage(
              childName: data['childName'] ?? 'Child',
              latitude: data['latitude'] != null ? (data['latitude'] as num).toDouble() : null,
              longitude: data['longitude'] != null ? (data['longitude'] as num).toDouble() : null,
              timestamp: data['timestamp'] ?? DateTime.now().toIso8601String(),
            ),
            transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          ),
        );
      }
    });
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() => _parentName = user['name'] ?? 'Parent');
    }

    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final res = await http.get(
        Uri.parse('${AppConstants.serverUrl}${AppConstants.childrenEndpoint}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final children = data['children'] as List;
        if (children.isNotEmpty) {
          final child = children.last;
          setState(() {
            _childId = child['id'] as int;
            _childName = child['name'] as String?;
          });
        } else {
          setState(() { _childId = null; _childName = null; });
        }
      }
    } catch (e) {
      print('❌ Failed to fetch children: $e');
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('You will need to sign in again to monitor your child.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    sl<SocketService>().disconnect();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    sl<SocketService>().off('sos:received');
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<LocationBloc>()),
        BlocProvider(create: (_) => sl<SoundAroundBloc>()),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: IndexedStack(
                index: _tab,
                children: [
                  const LocationPage(),
                  SoundAroundPage(childId: _childId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                child: const Center(child: Text('🦩', style: TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Flamingo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Hi, $_parentName 👋', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              // Pair button
              GestureDetector(
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const PairingPage()));
                  _loadUser();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: const Row(children: [
                    Icon(Icons.link_rounded, color: Colors.white, size: 15),
                    SizedBox(width: 4),
                    Text('Pair', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(width: 8),
              // Live badge
              BlocBuilder<LocationBloc, LocationState>(
                builder: (_, state) {
                  final live = state is LocationUpdated;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: live ? Colors.greenAccent.withOpacity(0.2) : Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: live ? Colors.greenAccent : Colors.white30),
                    ),
                    child: Row(children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: live ? Colors.greenAccent : Colors.white38)),
                      const SizedBox(width: 4),
                      Text(live ? 'LIVE' : 'OFFLINE', style: TextStyle(color: live ? Colors.greenAccent : Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                    ]),
                  );
                },
              ),
              const SizedBox(width: 8),
              // Logout
              GestureDetector(
                onTap: _logout,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = [
      (icon: Icons.location_on_rounded, label: 'Location'),
      (icon: Icons.hearing_rounded, label: 'Sound Around'),
    ];
    return Container(
      color: Colors.white,
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = _tab == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: active ? AppTheme.primary : Colors.transparent, width: 3)),
                ),
                child: Column(children: [
                  Icon(tabs[i].icon, color: active ? AppTheme.primary : Colors.grey.shade400, size: 22),
                  const SizedBox(height: 3),
                  Text(tabs[i].label, style: TextStyle(color: active ? AppTheme.primary : Colors.grey.shade400, fontSize: 12, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
