import '../../../../../features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/staff_ticket_provider.dart';
import 'ticket_detail_admin_page.dart';
import 'staff_create_ticket_page.dart';

class TicketQueuePage extends StatefulWidget {
  const TicketQueuePage({super.key});

  @override
  State<TicketQueuePage> createState() => _TicketQueuePageState();
}

class _TicketQueuePageState extends State<TicketQueuePage> {
  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final role = context.read<AuthProvider>().role;
      context.read<StaffTicketProvider>().loadAllTickets(role: role);
    });
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selectedIds.clear();
    });
  }

  void _toggleSelectAll(List<String> allIds) {
    setState(() {
      // Kalau semua sudah terpilih, "pilih semua" jadi "batal semua".
      // Kalau belum semua, pilih semua ID yang ada di list saat ini.
      if (_selectedIds.length == allIds.length) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(allIds);
      }
    });
  }

  Future<void> _confirmDelete() async {
    final count = _selectedIds.length;
    if (count == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tiket?'),
        content: Text(
          'Anda akan menghapus $count tiket beserta seluruh komentar, '
              'riwayat status, dan lampirannya secara permanen. Tindakan ini '
              'tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final provider = context.read<StaffTicketProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final role = context.read<AuthProvider>().role;
    final idsToDelete = _selectedIds.toList();

    setState(() => _isDeleting = true);

    try {
      await provider.deleteTickets(idsToDelete, role: role);

      if (!mounted) return;

      setState(() {
        _selectedIds.clear();
        _selectMode = false;
        _isDeleting = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text('$count tiket berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDeleting = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // BARU: navigasi ke halaman create ticket staff, lalu refresh list
  // setelah kembali -- pola ini SAMA PERSIS dengan onTap item tiket di
  // bawah (push ke TicketDetailAdminPage lalu loadAllTickets lagi).
  // loadAllTickets dipanggil TANPA updateFilter, jadi filter helpdesk
  // yang sedang aktif (kalau ada) tetap dipertahankan setelah refresh.
  Future<void> _openCreateTicket() async {
    final currentRole = context.read<AuthProvider>().role;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StaffCreateTicketPage(role: currentRole),
      ),
    );

    if (!mounted) return;
    context.read<StaffTicketProvider>().loadAllTickets(role: currentRole);
  }

  // BARU: dipanggil saat admin memilih helpdesk di dropdown filter
  // (FR-007.3 "Melihat semua tiket berdasarkan helpdesk yang
  // ditugaskan"). value null berarti admin memilih "Semua Helpdesk".
  // updateFilter: true supaya pilihan ini TERSIMPAN sebagai filter aktif,
  // bukan cuma sekali pakai.
  void _onFilterHelpdeskChanged(String? helpdeskId) {
    final role = context.read<AuthProvider>().role;
    context.read<StaffTicketProvider>().loadAllTickets(
      role: role,
      filterByHelpdeskId: helpdeskId,
      updateFilter: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StaffTicketProvider>();
    final tickets = provider.tickets;
    final role = context.watch<AuthProvider>().role;
    final isAdmin = role == 'admin';

    final allIds = tickets.map((t) => t.id).toList();
    final allSelected = allIds.isNotEmpty && _selectedIds.length == allIds.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectMode
            ? '${_selectedIds.length} dipilih'
            : 'Antrian Tiket'),
        leading: _selectMode
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isDeleting ? null : _toggleSelectMode,
        )
            : null,
        actions: [
          // Tombol "pilih" HANYA untuk admin -- helpdesk tidak diberi
          // opsi hapus sama sekali, sesuai keputusan yang sudah disepakati.
          if (isAdmin && tickets.isNotEmpty && !_selectMode)
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Pilih tiket',
              onPressed: _toggleSelectMode,
            ),
          if (_selectMode)
            IconButton(
              icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
              tooltip: allSelected ? 'Batalkan semua' : 'Pilih semua',
              onPressed: _isDeleting ? null : () => _toggleSelectAll(allIds),
            ),
        ],
      ),
      body: Column(
        children: [
          // BARU: dropdown filter helpdesk, HANYA untuk admin dan HANYA
          // saat tidak sedang _selectMode (supaya tidak mengganggu mode
          // pilih/hapus yang juga admin-only). Helpdesk tidak pernah
          // melihat dropdown ini -- daftar tiketnya sudah otomatis
          // ter-filter oleh assigned_to di repository, jadi dropdown
          // ini akan percuma/membingungkan untuknya.
          if (isAdmin && !_selectMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DropdownButtonFormField<String?>(
                initialValue: provider.filterHelpdeskId,
                decoration: const InputDecoration(
                  labelText: 'Filter berdasarkan Helpdesk',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Semua Helpdesk'),
                  ),
                  ...provider.helpdeskList.map((h) {
                    final name =
                    (h['full_name'] ?? h['username'] ?? '-').toString();
                    return DropdownMenuItem<String?>(
                      value: h['id'] as String,
                      child: Text(name),
                    );
                  }),
                ],
                onChanged: _onFilterHelpdeskChanged,
              ),
            ),
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : tickets.isEmpty
                ? const Center(child: Text('Belum ada tiket'))
                : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                final isSelected = _selectedIds.contains(ticket.id);

                return Card(
                  child: ListTile(
                    leading: _selectMode
                        ? Checkbox(
                      value: isSelected,
                      onChanged: _isDeleting
                          ? null
                          : (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedIds.add(ticket.id);
                          } else {
                            _selectedIds.remove(ticket.id);
                          }
                        });
                      },
                    )
                        : null,
                    title: Text(ticket.title),
                    subtitle:
                    Text('${ticket.id} • ${ticket.userName} • ${ticket.status}'),
                    trailing: _selectMode ? null : const Icon(Icons.chevron_right),
                    onTap: _selectMode
                        ? (_isDeleting
                        ? null
                        : () {
                      setState(() {
                        if (isSelected) {
                          _selectedIds.remove(ticket.id);
                        } else {
                          _selectedIds.add(ticket.id);
                        }
                      });
                    })
                        : () async {
                      final currentRole = context.read<AuthProvider>().role;

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TicketDetailAdminPage(ticketId: ticket.id),
                        ),
                      );

                      if (!mounted) return;
                      context.read<StaffTicketProvider>().loadAllTickets(role: currentRole);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // BARU: saat _selectMode nonaktif (kondisi normal browsing antrian),
      // FAB dipakai untuk buat tiket baru. Saat _selectMode aktif, perilaku
      // LAMA dipertahankan persis (FAB hapus, atau null kalau belum ada
      // yang dicentang) -- tidak ada logika lama yang hilang.
      floatingActionButton: _selectMode
          ? (_selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: _isDeleting ? null : _confirmDelete,
        backgroundColor: Colors.red,
        icon: _isDeleting
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        )
            : const Icon(Icons.delete_outline),
        label: Text('Hapus (${_selectedIds.length})'),
      )
          : null)
          : FloatingActionButton(
        onPressed: _openCreateTicket,
        tooltip: 'Buat Tiket',
        child: const Icon(Icons.add),
      ),
    );
  }
}