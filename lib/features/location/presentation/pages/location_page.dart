import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../bloc/location_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});
  @override State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final MapController _mapCtrl = MapController();
  LatLng? _childLatLng;
  String _childName = '';
  String _lastSeen = '';
  bool _mapReady = false;
  LocationBloc? _bloc;

  static const LatLng _defaultCenter = LatLng(20.5937, 78.9629);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<LocationBloc>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationBloc>().add(const StartWatchingLocation());
    });
  }

  @override
  void dispose() {
    _bloc?.add(const StopWatchingLocation());
    _mapCtrl.dispose();
    super.dispose();
  }

  void _onLocationUpdated(LocationUpdated state) {
    setState(() {
      _childLatLng = LatLng(state.location.latitude, state.location.longitude);
      _childName = state.location.childName;
      _lastSeen = _formatTime(state.location.timestamp);
    });
    if (_mapReady) _mapCtrl.move(_childLatLng!, AppConstants.defaultZoom);
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocationBloc, LocationState>(
      listener: (ctx, state) {
        if (state is LocationUpdated) _onLocationUpdated(state);
      },
      builder: (ctx, state) => Stack(
        children: [
          _buildMap(),
          if (_childLatLng == null) _buildWaiting(),
          Positioned(bottom: 20, left: 16, right: 16, child: _buildCard(state)),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapCtrl,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 4,
        onMapReady: () {
          _mapReady = true;
          if (_childLatLng != null) {
            _mapCtrl.move(_childLatLng!, AppConstants.defaultZoom);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.flamingo.parent',
        ),
        if (_childLatLng != null)
          MarkerLayer(markers: [
            Marker(
              point: _childLatLng!,
              width: 56,
              height: 64,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0,4))],
                    ),
                    child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 24),
                  ),
                  CustomPaint(size: const Size(14, 7), painter: _TrianglePainter()),
                ],
              ),
            ),
          ]),
      ],
    );
  }

  Widget _buildWaiting() {
    return Positioned.fill(
      child: Container(
        color: AppTheme.background.withOpacity(0.92),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient.scale(0.3),
              ),
              child: const Icon(Icons.location_searching_rounded, size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            const Text('Waiting for location...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
            const SizedBox(height: 6),
            Text('Make sure the child app is running', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(LocationState state) {
    final isLive = state is LocationUpdated;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.15), blurRadius: 24, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isLive ? AppTheme.primaryGradient : const LinearGradient(colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)]),
            ),
            child: const Icon(Icons.child_care_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLive ? _childName : 'Your Child',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  isLive
                    ? '${(state as LocationUpdated).location.latitude.toStringAsFixed(5)}, ${state.location.longitude.toStringAsFixed(5)}'
                    : 'Waiting for location...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
                if (isLive && _lastSeen.isNotEmpty)
                  Text('Updated at $_lastSeen', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isLive ? AppTheme.success.withOpacity(0.12) : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(width: 7, height: 7, decoration: BoxDecoration(shape: BoxShape.circle, color: isLive ? AppTheme.success : Colors.grey.shade400)),
                const SizedBox(width: 5),
                Text(isLive ? 'LIVE' : 'OFF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isLive ? AppTheme.success : Colors.grey.shade400)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..color = const Color(0xFFFF9A3C);
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }
  @override bool shouldRepaint(_) => false;
}
