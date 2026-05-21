import 'package:flutter/material.dart';
import '../models/reserva.dart';
import '../services/hotel_api_service.dart';
import '../theme/app_theme.dart';

class ReservationsScreen extends StatefulWidget {
  final bool showBackButton;
  const ReservationsScreen({super.key, this.showBackButton = false});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final _api = HotelApiService();
  late Future<List<Reserva>> _future;
  String _filter = 'TODAS';

  @override
  void initState() {
    super.initState();
    _future = _api.misReservas();
  }

  Future<void> _reload() async {
    setState(() => _future = _api.misReservas());
    await _future;
  }

  Future<void> _cancelar(Reserva reserva) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar reserva'),
        content: Text(
            '¿Cancelar la reserva de la habitación ${reserva.habitacionNumero}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sí, cancelar')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _api.cancelarReserva(reserva.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reserva cancelada')));
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString()), backgroundColor: Colors.redAccent));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F7),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
                child: _Header(
                    showBackButton: widget.showBackButton, onReload: _reload)),
            SliverToBoxAdapter(
                child: _Filters(
                    value: _filter,
                    onChanged: (v) => setState(() => _filter = v))),
            FutureBuilder<List<Reserva>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return SliverFillRemaining(
                      child: _Empty(
                          icon: Icons.wifi_off,
                          text: snapshot.error.toString()));
                }
                var reservas = snapshot.data ?? [];
                if (_filter != 'TODAS') {
                  reservas =
                      reservas.where((r) => r.estado == _filter).toList();
                }
                if (reservas.isEmpty) {
                  return const SliverFillRemaining(
                      child: _Empty(
                          icon: Icons.event_busy,
                          text: 'Aún no tienes reservas en esta sección.'));
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList.separated(
                    itemCount: reservas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _ReservationCard(
                        reserva: reservas[i],
                        onCancelar: () => _cancelar(reservas[i])),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool showBackButton;
  final Future<void> Function() onReload;
  const _Header({required this.showBackButton, required this.onReload});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.headerPurple,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 12,
        right: 12,
        bottom: 20,
      ),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white)),
          const Expanded(
            child: Text('Mis Reservas',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
          ),
          IconButton(
              onPressed: onReload,
              icon: const Icon(Icons.refresh, color: Colors.white70)),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _Filters({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const items = ['TODAS', 'PENDIENTE', 'CONFIRMADA', 'CANCELADA'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: items.map((item) {
          final active = item == value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(item),
              selected: active,
              onSelected: (_) => onChanged(item),
              selectedColor: AppColors.gold,
              labelStyle:
                  TextStyle(color: active ? Colors.white : AppColors.textDark),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reserva reserva;
  final VoidCallback onCancelar;
  const _ReservationCard({required this.reserva, required this.onCancelar});

  @override
  Widget build(BuildContext context) {
    final color = switch (reserva.estado) {
      'CONFIRMADA' => Colors.green,
      'CANCELADA' => Colors.redAccent,
      _ => AppColors.backButton,
    };
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: reserva.habitacionImagenUrl == null
                      ? Container(
                          color: const Color(0xFFECE7D5),
                          child: const Center(
                              child:
                                  Text('🏨', style: TextStyle(fontSize: 28))))
                      : Image.network(reserva.habitacionImagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Text('🏨'))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '${reserva.habitacionTipo} · Hab. ${reserva.habitacionNumero}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textDark)),
                    const SizedBox(height: 4),
                    Text(
                        '${_format(reserva.fechaEntrada)} - ${_format(reserva.fechaSalida)}',
                        style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(reserva.estado,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${reserva.adultos} adulto(s) · ${reserva.ninos} niño(s)',
                  style: const TextStyle(color: Colors.black54)),
              Text('\$${reserva.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          ),
          if (reserva.estado != 'CANCELADA') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancelar,
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancelar reserva'),
              ),
            ),
          ]
        ],
      ),
    );
  }

  static String _format(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 62, color: Colors.grey),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
