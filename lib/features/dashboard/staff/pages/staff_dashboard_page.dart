import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projectuts/core/routes/route_names.dart';
import 'package:projectuts/core/widgets/dashboard_stat_card.dart';
import 'package:projectuts/features/auth/presentation/providers/auth_provider.dart';
import 'package:projectuts/features/tickets/staff/presentation/pages/staff_create_ticket_page.dart';
import '../providers/staff_dashboard_provider.dart';

class StaffDashboardPage extends StatefulWidget {
  const StaffDashboardPage({super.key});

  @override
  State<StaffDashboardPage> createState() => _StaffDashboardPageState();
}

class _StaffDashboardPageState extends State<StaffDashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final role = context.read<AuthProvider>().role;
      context.read<StaffDashboardProvider>().loadStats(role: role);
    });
  }

  // BARU: navigasi ke halaman create ticket staff, lalu refresh statistik
  // dashboard setelah kembali -- supaya kartu "Total"/"Open" langsung
  // update begitu tiket baru selesai dibuat, sama seperti behaviour
  // refresh yang sudah ada di TicketQueuePage.
  Future<void> _openCreateTicket(String role) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffCreateTicketPage(role: role),
      ),
    );

    if (!mounted) return;
    context.read<StaffDashboardProvider>().loadStats(role: role);
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StaffDashboardProvider>();
    final role = context.watch<AuthProvider>().role;

    // Menu dasar, dimiliki Admin & Helpdesk (FR-006 & FR-007).
    // "Respon Tiket" DIHAPUS dari sini -- fungsinya sudah tersedia di
    // dalam Antrian Tiket (tap salah satu tiket untuk merespon & ubah
    // status), jadi menu terpisah ini jadi duplikat dan dihapus.
    final items = [
      ('Antrian Tiket', Icons.inbox_outlined, RouteNames.ticketQueue),
      // "Assign Tiket" & "Kelola User" cuma muncul untuk admin (FR-007.4 & FR-007.7)
      if (role == 'admin') ...[
        ('Assign Tiket', Icons.person_add_alt_1_outlined, RouteNames.ticketAssign),
        ('Kelola User', Icons.people_alt_outlined, RouteNames.manageUser),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(role == 'admin' ? 'Dashboard Admin' : 'Dashboard Helpdesk'),
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
          Text(
            role == 'admin'
                ? 'Ringkasan semua tiket'
                : 'Ringkasan tiket saya',
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // 5 kategori sesuai FR-009: Total, Open, Assign, In Progress, Closed
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
          const Text('Menu Utama',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: [
              // BARU: "Buat Tiket" muncul untuk admin & helpdesk (tanpa
              // kondisi if), sama seperti "Antrian Tiket" di atas --
              // sesuai FR-006.1 & FR-007.1, kedua role sama-sama boleh
              // membuat tiket. Dipisah dari GridView.builder di bawah
              // (yang isinya named-route) karena card ini butuh
              // Navigator.push + widget builder, bukan pushNamed(String).
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openCreateTicket(role),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline, size: 36, color: Colors.blueAccent),
                      SizedBox(height: 10),
                      Text('Buat Tiket',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              ...items.map((item) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
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
                            style: const TextStyle(
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}