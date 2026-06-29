import 'package:flutter/material.dart';
import '../models/drive_session.dart';
import '../utils/app_theme.dart';

class EventLogWidget extends StatelessWidget {
  final List<DriveEvent> events;
  final bool scrollable;
  final int? maxItems;

  const EventLogWidget({
    super.key,
    required this.events,
    this.scrollable = false,
    this.maxItems,
  });

  String _timeAgo(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    return '${diff.inHours}h ago';
  }

  @override
  Widget build(BuildContext context) {
    final reversed = events.reversed.toList();
    final displayed = maxItems != null && reversed.length > maxItems!
        ? reversed.sublist(0, maxItems!)
        : reversed;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          const Row(
            children: [
              Expanded(
                child: Text('Activity',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
              SizedBox(
                width: 85,
                child: Text('Time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
              SizedBox(
                width: 55,
                child: Text('Points',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 4),

          if (events.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('No events yet',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textMuted)),
              ),
            )
          else
            ...displayed.asMap().entries.map((entry) {
              final e = entry.value;
              final isLast = entry.key == displayed.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.type,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 85,
                          child: Text(
                            _timeAgo(e.timestamp),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 55,
                          child: Text(
                            '-${e.pointsDeducted}',
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF5252),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(color: AppColors.divider, height: 1),
                ],
              );
            }),
        ],
      ),
    );
  }
}
