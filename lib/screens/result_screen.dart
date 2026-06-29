import 'package:flutter/material.dart';
import '../models/drive_session.dart';
import '../utils/app_theme.dart';
import '../widgets/score_meter.dart';
import '../widgets/info_card.dart';
import '../widgets/event_log_widget.dart';

class ResultScreen extends StatelessWidget {
  final DriveSession session;

  const ResultScreen({super.key, required this.session});

  Color get _statusColor {
    if (session.finalScore >= 75) return AppColors.green;
    if (session.finalScore >= 50) return AppColors.yellow;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // Meter
                ScoreMeter(score: session.finalScore),

                const SizedBox(height: 8),

                // Status
                const Text(
                  'Status:',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  session.statusText,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _statusColor,
                  ),
                ),

                const SizedBox(height: 20),

                // Time taken + Distance
                Row(
                  children: [
                    InfoCard(
                        label: 'Time taken',
                        value: session.durationFormatted),
                    const SizedBox(width: 12),
                    InfoCard(
                        label: 'Distance',
                        value: '${session.distanceKm} km'),
                  ],
                ),

                const SizedBox(height: 16),

                // Full event log
                EventLogWidget(events: session.events),

                const SizedBox(height: 20),

                // Back to home
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green, width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Back to home',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
