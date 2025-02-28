import 'package:flutter/material.dart';

class TransactionStatus {
  final String id;
  final String status;
  final IconData icon;
  final Color color;

  const TransactionStatus({
    required this.id,
    required this.status,
    required this.icon,
    required this.color,
  });
}