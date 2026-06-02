import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:ui' as ui;

class SosAlertPage extends StatefulWidget {
  final String childName;
  final double? latitude;
  final double? longitude;
  final String timestamp;

  const SosAlertPage({
    super.key,
    required this.childName,
    this.latitude,
    this.longitude,
    required this.timestamp,
  });

  @override
  State<SosAlertPage> createState() => _SosAlertPageState();
}

class _SosAlertPageState extends State<SosAlertPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _pulse;
  late Animation<double> _fade;
  final MapController _mapCtrl = MapController();
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _pulse = Tween<double>(begin: 1.0, end: 1.12)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _fadeCtrl.dispose();
    _mapCtrl.dispose();
    super.dispose();
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasLocation = widget.latitude != null && widget.longitude != null;

    return FadeTransition(
      opacity: _fade,
      child: Scaffold(
        backgroundColor: Colors.red.shade900,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulse,
                      builder: (_, child) =>
                          Transform.scale(scale: _pulse.value, child: child),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.red.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 10),
                          ],
                        ),
                        child: const Icon(Icons.sos_rounded,
                            color: Colors.red, size: 44),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🚨 SOS ALERT',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${widget.childName} needs help!',
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sent at ${_formatTime(widget.timestamp)}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Map
              Expanded(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: hasLocation
                        ? FlutterMap(
                            mapController: _mapCtrl,
                            options: MapOptions(
                              initialCenter: LatLng(
                                  widget.latitude!, widget.longitude!),
                              initialZoom: 15,
                              onMapReady: () {
                                _mapReady = true;
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName:
                                    'com.flamingo.parent',
                              ),
                              MarkerLayer(markers: [
                                Marker(
                                  point: LatLng(
                                      widget.latitude!, widget.longitude!),
                                  width: 60,
                                  height: 70,
                                  child: Column(
                                    children: [
                                      AnimatedBuilder(
                                        animation: _pulse,
                                        builder: (_, child) =>
                                            Transform.scale(
                                                scale: _pulse.value,
                                                child: child),
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red,
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.red
                                                      .withOpacity(0.6),
                                                  blurRadius: 16,
                                                  spreadRadius: 4),
                                            ],
                                          ),
                                          child: const Icon(
                                              Icons.person_pin_rounded,
                                              color: Colors.white,
                                              size: 28),
                                        ),
                                      ),
                                      CustomPaint(
                                        size: const Size(14, 7),
                                        painter: _TrianglePainter(),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            ],
                          )
                        : Container(
                            color: Colors.grey.shade800,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_off_rounded,
                                      color: Colors.white54, size: 48),
                                  SizedBox(height: 12),
                                  Text('Location not available',
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // Location info
              if (hasLocation)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.latitude!.toStringAsFixed(6)}, ${widget.longitude!.toStringAsFixed(6)}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),

              // Dismiss button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.red.shade900,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text(
                      'Dismiss Alert',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = ui.Paint()..color = Colors.red;
    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
