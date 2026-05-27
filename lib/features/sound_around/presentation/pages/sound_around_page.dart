import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/sound_around_bloc.dart';

class SoundAroundPage extends StatefulWidget {
  final int? childId;
  const SoundAroundPage({super.key, this.childId});
  @override State<SoundAroundPage> createState() => _SoundAroundPageState();
}

class _SoundAroundPageState extends State<SoundAroundPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _waveCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _waveCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SoundAroundBloc, SoundAroundState>(
      listener: (ctx, state) {
        if (state is SoundAroundError) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
            content: Text(state.message),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }
      },
      builder: (ctx, state) {
        final isActive  = state is SoundAroundActive;
        final isLoading = state is SoundAroundLoading;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _buildMicButton(ctx, state, isActive, isLoading),
              const SizedBox(height: 28),
              Text(
                isLoading ? 'Connecting...' : isActive ? 'Listening to surroundings' : 'Sound Around',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                isActive ? 'Tap again to stop listening' : 'Tap the mic to hear your child\'s surroundings',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 36),
              if (isActive) _buildWaveVisualizer(),
              const SizedBox(height: 36),
              _buildInfoCard(Icons.info_outline_rounded, 'How it works',
                'Your child\'s phone microphone activates silently. You hear their surroundings in real time.', AppTheme.accent),
              const SizedBox(height: 12),
              _buildInfoCard(Icons.shield_outlined, 'Privacy',
                'A visible indicator always shows on the child\'s phone when the mic is active.', AppTheme.secondary),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMicButton(BuildContext ctx, SoundAroundState state, bool isActive, bool isLoading) {
    final childId = widget.childId ?? 0;
    return GestureDetector(
      onTap: isLoading ? null : () {
        if (isActive) {
          final s = state as SoundAroundActive;
          ctx.read<SoundAroundBloc>().add(DeactivateSoundAround(s.childId, s.sessionId));
        } else {
          ctx.read<SoundAroundBloc>().add(ActivateSoundAround(childId));
        }
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (_, child) => Transform.scale(scale: isActive ? _pulse.value : 1.0, child: child),
        child: Container(
          width: 148, height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isActive
              ? const LinearGradient(colors: [Color(0xFFFF5C7C), Color(0xFFFF9A3C)], begin: Alignment.topLeft, end: Alignment.bottomRight)
              : AppTheme.purpleGradient,
            boxShadow: [BoxShadow(
              color: (isActive ? AppTheme.error : AppTheme.accent).withOpacity(0.45),
              blurRadius: 36, spreadRadius: 6,
            )],
          ),
          child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Icon(isActive ? Icons.mic_rounded : Icons.mic_none_rounded, color: Colors.white, size: 64),
        ),
      ),
    );
  }

  Widget _buildWaveVisualizer() {
    return AnimatedBuilder(
      animation: _waveCtrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(9, (i) {
          final h = 12.0 + 36 * ((_waveCtrl.value + i * 0.12) % 1.0);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 7, height: h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: AppTheme.primaryGradient,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String body, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 4),
              Text(body, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4)),
            ],
          )),
        ],
      ),
    );
  }
}
