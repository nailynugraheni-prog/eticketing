import 'package:flutter/material.dart';

/// Kartu statistik dashboard, dipakai BERSAMA oleh StaffDashboardPage dan
/// UserDashboardPage. Sebelumnya masing-masing halaman punya widget kartu
/// sendiri (_buildStatCard di staff, _buildSimpleStat di user) dengan
/// layout yang berbeda -- staff pakai Column rata kiri, user pakai Column
/// rata tengah. Sekarang disatukan jadi satu fungsi supaya style benar-benar
/// identik di kedua dashboard, bukan cuma "terlihat mirip".
Widget buildDashboardStatCard(String title, String value, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title,
            style: TextStyle(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.bold)),
        Text(value,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    ),
  );
}