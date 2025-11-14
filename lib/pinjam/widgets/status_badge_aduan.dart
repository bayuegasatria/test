import 'package:flutter/material.dart';

class StatusBadgeAduan extends StatelessWidget {
  final String status;

  const StatusBadgeAduan({super.key, required this.status});

  Color getStatusColor(String status) {
    switch (status) {
      case "Selesai Diproses":
        return Colors.green;
      case "Sedang Diproses":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case "Selesai Diproses":
        return Icons.check_circle;
      case "Sedang Diproses":
        return Icons.access_time;
      default:
        return Icons.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(getStatusIcon(status), color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
