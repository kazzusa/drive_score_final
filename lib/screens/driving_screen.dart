import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/driving_service.dart';
import '../services/session_storage.dart';
import '../utils/app_theme.dart';
import '../widgets/score_meter.dart';
import '../widgets/info_card.dart';
import '../widgets/event_log_widget.dart';
import 'result_screen.dart';

class DrivingScreen extends StatefulWidget {
  final DrivingService service;

  const DrivingScreen({super.key, required this.service});

  @override
  State<DrivingScreen> createState() => _DrivingScreenState();
}

class _DrivingScreenState extends State<DrivingScreen> {
  String _currentTime = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    widget.service.addListener(_onServiceUpdate);
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('h:mm a').format(DateTime.now());
    });
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) _updateTime();
    });
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  Future<void> _onStop() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Stop drive?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will end your current session and show your final score.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Stop',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final session = widget.service.stopDrive();
    await SessionStorage.saveSession(session);

    if (!mounted) return;

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResultScreen(session: session),
      ),
    );
  }

  String _formatDist(double km) {
    return '${km.toStringAsFixed(1)} km';
  }

  String _formatSpeed(double kmh) {
    return '${kmh.toStringAsFixed(0)} km/h';
  }

  @override
  void dispose() {
    widget.service.removeListener(_onServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final svc = widget.service;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Score meter
                ScoreMeter(score: svc.score),

                const SizedBox(height: 25),

                // Time + Distance row
                Row(
                  children: [
                    InfoCard(label: 'Time', value: _currentTime),
                    const SizedBox(width: 12),
                    InfoCard(label: 'Distance', value: _formatDist(svc.distanceKm)),
                  ],
                ),

                const SizedBox(height: 25),

                // Speed row
                Row(
                  children: [
                    Expanded(child: InfoCard(label: 'Speed', value: _formatSpeed(svc.currentSpeedKmh))),
                  ],
                ),

                const SizedBox(height: 20),

                // Stop button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onStop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Stop',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Event log
                EventLogWidget(
                  events: svc.events,
                  maxItems: 5,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
