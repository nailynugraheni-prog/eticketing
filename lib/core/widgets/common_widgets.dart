import 'package:flutter/material.dart';

class CommonWidgets {
  static Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Widget customButton({
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  static Widget statusChip(String status) {
    return Chip(
      label: Text(status),
    );
  }
}