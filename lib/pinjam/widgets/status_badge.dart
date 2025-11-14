import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final Color Function(String) getStatusColor;

  const StatusBadge({
    super.key,
    required this.status,
    required this.getStatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: getStatusColor(status).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              status.toLowerCase() == "y"
                  ? Icons.check_circle
                  : status.toLowerCase() == "n"
                  ? Icons.cancel
                  : status.toLowerCase() == "c"
                  ? Icons.delete_forever
                  : Icons.access_time,
              color: getStatusColor(status),
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              status.toLowerCase() == "y"
                  ? "Disetujui"
                  : status.toLowerCase() == "n"
                  ? "Ditolak"
                  : status.toLowerCase() == "c"
                  ? "Dibatalkan"
                  : "Menunggu",
              style: TextStyle(
                color: getStatusColor(status),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
