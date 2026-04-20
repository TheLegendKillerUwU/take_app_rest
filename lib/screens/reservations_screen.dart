import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  int _tab = 0;
  final List<String> _tabs = ['Próximas', 'Pasadas', 'Canceladas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F7),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.headerPurple,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mis Reservas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(Icons.more_horiz,
                          color: Colors.white54, size: 26),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tabs
                  Row(
                    children: _tabs.asMap().entries.map((e) {
                      final active = e.key == _tab;
                      return GestureDetector(
                        onTap: () => setState(() => _tab = e.key),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: active
                                ? null
                                : Border.all(color: Colors.white24, width: 1),
                          ),
                          child: Text(
                            e.value,
                            style: TextStyle(
                              color: active ? Colors.white : Colors.white60,
                              fontSize: 13,
                              fontWeight:
                                  active ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

          // Lista de reservas
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: _tab == 0
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      _ReservationCard(
                        hotelName: 'Hotel Mencho',
                        roomType: 'Suite Ejecutiva, CDMX',
                        status: 'Próxima',
                        statusColor: AppColors.backButton,
                        checkIn: '15 Jul',
                        checkOut: '18 Jul 2025',
                        price: '\$3,100',
                      ),
                      const SizedBox(height: 12),
                      _ReservationCard(
                        hotelName: 'Hotel Mencho',
                        roomType: 'Suite Ejecutiva, CDMX',
                        status: 'Próxima',
                        statusColor: AppColors.backButton,
                        checkIn: '22 Ago',
                        checkOut: '25 Ago 2025',
                        price: '\$3,100',
                      ),
                    ]),
                  )
                : SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 60, color: Colors.grey.withOpacity(0.4)),
                            const SizedBox(height: 12),
                            Text(
                              'No hay reservas ${_tabs[_tab].toLowerCase()}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Reservation Card ──────────────────────────────────────────────────────────

class _ReservationCard extends StatelessWidget {
  final String hotelName, roomType, status, checkIn, checkOut, price;
  final Color statusColor;

  const _ReservationCard({
    required this.hotelName,
    required this.roomType,
    required this.status,
    required this.statusColor,
    required this.checkIn,
    required this.checkOut,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono hotel
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF0EAD6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🏨', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      hotelName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(roomType,
                    style: const TextStyle(
                        color: Color(0xFF888888), fontSize: 13)),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Check-in  —  Check-out',
                  style: TextStyle(color: Color(0xFF999999), fontSize: 11),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$checkIn - $checkOut',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      price,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
