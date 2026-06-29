import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/drive_session.dart';
import '../services/session_storage.dart';
import '../utils/app_theme.dart';
import '../widgets/score_meter.dart';
import '../widgets/event_log_widget.dart';

class SessionDetailScreen extends StatelessWidget {
  final DriveSession session;

  const SessionDetailScreen({super.key, required this.session});

  Color get _statusColor {
    if (session.finalScore >= 85) return AppColors.green;
    if (session.finalScore >= 60) return AppColors.yellow;
    return AppColors.red;
  }

  Future<void> _deleteSession(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete session?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This session will be permanently removed from your history.',
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
            child: const Text('Delete',
                style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await SessionStorage.deleteSession(session);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Session details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.red),
            onPressed: () => _deleteSession(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),

              ScoreMeter(score: session.finalScore),

              const SizedBox(height: 8),

              const Text(
                'Status:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

              // Stats grid
              Row(
                children: [
                  _StatCard(
                    label: 'Date',
                    value: DateFormat('d MMM yyyy').format(session.startTime),
                    valueStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Duration',
                    value: session.durationFormatted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatCard(
                    label: 'Distance',
                    value: '${session.distanceKm} km',
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    label: 'Events',
                    value: '${session.events.length}',
                    valueStyle: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              EventLogWidget(events: session.events),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _StatCard({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
