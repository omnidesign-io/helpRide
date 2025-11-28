import 'package:flutter/material.dart';
import 'package:helpride/features/rides/domain/ride_model.dart';
import 'package:helpride/features/rides/domain/ride_status_extension.dart';

class StatusChip extends StatelessWidget {
  final RideStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.localized(context),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.pending:
        return const Color(0xFFFF9800); // Orange
      case RideStatus.accepted:
        return const Color(0xFF2196F3); // Blue
      case RideStatus.arrived:
        return const Color(0xFF9C27B0); // Purple
      case RideStatus.riding:
        return const Color(0xFF4CAF50); // Green
      case RideStatus.completed:
        return const Color(0xFF9E9E9E); // Grey
      case RideStatus.cancelled:
        return const Color(0xFFF44336); // Red
    }
  }
}
