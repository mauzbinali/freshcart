import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';

class AppUtils {
  static String formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy · hh:mm a').format(date);
  }

  // FIX: overlay_support toast — works without BuildContext
  static void showToast(String message, {bool isError = false}) {
    showSimpleNotification(
      Text(message, style: const TextStyle(color: Colors.white)),
      background: isError ? Colors.red.shade700 : Colors.black87,
      duration: const Duration(seconds: 2),
      position: NotificationPosition.bottom,
    );
  }

  static void showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  static String generateOrderId() {
    final now = DateTime.now();
    return 'FC-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  static String shortId(String id) {
    if (id.isEmpty) return 'UNKNOWN';
    return (id.length <= 8 ? id : id.substring(0, 8)).toUpperCase();
  }

  static String firstInitial(String? value, {String fallback = 'U'}) {
    final trimmed = value?.trim() ?? '';
    return (trimmed.isEmpty ? fallback : trimmed.characters.first)
        .toUpperCase();
  }

  static String firstName(String? value, {String fallback = 'there'}) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return fallback;
    return trimmed.split(RegExp(r'\s+')).first;
  }

  static String statusLabel(String status) {
    final trimmed = status.trim();
    if (trimmed.isEmpty) return 'Unknown';
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'processing':
        return Icons.sync;
      case 'shipped':
        return Icons.local_shipping;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}
