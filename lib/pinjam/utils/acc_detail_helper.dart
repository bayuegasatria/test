import 'package:flutter/material.dart';

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case "y":
      return Colors.green;
    case "n":
      return Colors.red;
    case "c":
      return Colors.orange;
    default:
      return Colors.yellow;
  }
}
