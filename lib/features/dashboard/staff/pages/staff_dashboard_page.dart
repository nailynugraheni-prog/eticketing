import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/route_names.dart';
import '../providers/staff_dashboard_provider.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Panggil Provider buat ambil angka statistik
    final stats = context.watch<StaffDashboardProvider>();

    final items = [
      ('Antrian Tiket', Icons.inbox_outlined, RouteNames.ticketQueue),
      ('Detail Tiket', Icons.description_outlined, RouteNames.ticketDetailAdmin),
      ('Respon Tiket', Icons.reply_outlined, RouteNames.ticketResponse),
      ('Ubah Status', Icons.update_outlined, RouteNames.ticketStatusUpdate),
      ('Assign Tiket', Icons.person_add_alt_1_outlined, RouteNames.ticketAssign),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin / Helpdesk'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.login),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView( // Pakai ListView supaya bisa scroll kalau statistik + menu kepanjangan
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Ringkasan Tiket',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- BAGIAN STATISTIK ---
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              _buildStatCard('Total', '${stats.totalTickets}', Colors.blue),
              _buildStatCard('Baru', '${stats.newTickets}', Colors.orange),
              _buildStatCard('Proses', '${stats.onProgressTickets}', Colors.amber),
              _buildStatCard('Selesai', '${stats.doneTickets}', Colors.green),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Menu Utama',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- BAGIAN MENU (GRID) ---
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 2,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, item.$3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$2, size: 34, color: Colors.blueGrey),
                      const SizedBox(height: 10),
                      Text(item.$1, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Widget tambahan buat bikin kartu statistik
  Widget _buildStatCard(String title, String value, Color color) {
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
          Text(title, style: TextStyle(color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
