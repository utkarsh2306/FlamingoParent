import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/service_locator.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../location/presentation/pages/location_page.dart';
import '../../../sound_around/presentation/bloc/sound_around_bloc.dart';
import '../../../sound_around/presentation/pages/sound_around_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _tab = 0;
  String _parentName = 'Parent';
  int? _childId;
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      final user = jsonDecode(userJson);
      setState(() {
        _parentName = user['name'] ?? 'Parent';
        _childId = user['childId'];
      });
    }
  }

  @override
  void dispose() {
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
              // Flamingo logo
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14)),
                child: const Center(
                    child: Text('🦩', style: TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Flamingo',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3)),
                    Text('Hi, $_parentName 👋',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
              BlocBuilder<LocationBloc, LocationState>(
                builder: (_, state) {
                  final live = state is LocationUpdated;
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: live
                          ? Colors.greenAccent.withOpacity(0.2)
                          : Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: live ? Colors.greenAccent : Colors.white30),
                    ),
                    child: Row(children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  live ? Colors.greenAccent : Colors.white38)),
                      const SizedBox(width: 5),
                      Text(live ? 'LIVE' : 'OFFLINE',
                          style: TextStyle(
                              color: live ? Colors.greenAccent : Colors.white54,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ]),
                  );
                },
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
                  border: Border(
                      bottom: BorderSide(
                          color: active ? AppTheme.primary : Colors.transparent,
                          width: 3)),
                ),
                child: Column(children: [
                  Icon(tabs[i].icon,
                      color: active ? AppTheme.primary : Colors.grey.shade400,
                      size: 22),
                  const SizedBox(height: 3),
                  Text(tabs[i].label,
                      style: TextStyle(
                          color:
                              active ? AppTheme.primary : Colors.grey.shade400,
                          fontSize: 12,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal)),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }
}
