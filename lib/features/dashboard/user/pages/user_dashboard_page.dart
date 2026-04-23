import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/route_names.dart';
import '../providers/user_dashboard_provider.dart';

class UserDashboardPage extends StatelessWidget {
  const UserDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data sesuai nama variabel di providermu
    final stats = context.watch<UserDashboardProvider>();

    final items = [
      ('Buat Tiket', Icons.add_circle_outline, RouteNames.ticketCreate),
      ('Daftar Tiket', Icons.list_alt_outlined, RouteNames.ticketList),
      ('Tracking', Icons.track_changes_outlined, RouteNames.ticketTracking),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard User'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushReplacementNamed(context, RouteNames.login),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Progres Tiket Saya',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- STATISTIK DISESUAIKAN DENGAN PROVIDERMU ---
          Row(
            children: [
              _buildSimpleStat('Terbuka', '${stats.openTickets}', Colors.orange),
              const SizedBox(width: 8),
              _buildSimpleStat('Proses', '${stats.inProgressTickets}', Colors.blue),
              const SizedBox(width: 8),
              _buildSimpleStat('Selesai', '${stats.closedTickets}', Colors.green),
            ],
          ),

          const SizedBox(height: 24),
          const Text(
            'Layanan Helpdesk',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // --- GRID MENU ---
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pushNamed(context, item.$3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$2, size: 36, color: Colors.blueAccent),
                      const SizedBox(height: 10),
                      Text(item.$1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w500)
                      ),
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

  Widget _buildSimpleStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
