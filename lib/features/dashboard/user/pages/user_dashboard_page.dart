import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/widgets/dashboard_stat_card.dart';
import '../providers/user_dashboard_provider.dart';

class UserDashboardPage extends StatefulWidget {
  const UserDashboardPage({super.key});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<UserDashboardProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: () => Navigator.pushReplacementNamed(
                context, RouteNames.login),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: stats.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Progres Tiket Saya',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          // 5 kategori sesuai FR-009, style disamakan dengan dashboard staff
          // (sebelumnya cuma 3 kategori dalam Row sejajar: Terbuka/Proses/Selesai)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: [
              buildDashboardStatCard('Total', '${stats.totalTickets}', Colors.blue),
              buildDashboardStatCard('Open', '${stats.openTickets}', Colors.orange),
              buildDashboardStatCard('Assign', '${stats.assignedTickets}', Colors.purple),
              buildDashboardStatCard('In Progress', '${stats.inProgressTickets}', Colors.amber),
              buildDashboardStatCard('Closed', '${stats.closedTickets}', Colors.green),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Layanan Helpdesk',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      Navigator.pushNamed(context, item.$3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.$2,
                          size: 36, color: Colors.blueAccent),
                      const SizedBox(height: 10),
                      Text(item.$1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500)),
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
}