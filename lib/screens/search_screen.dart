import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  DateTime _focusedMonth = DateTime(2024, 5);
  DateTime? _selectedStart;
  DateTime? _selectedEnd;
  int _adults = 2;
  int _children = 0;

  static const List<String> _dayLabels = [
    'Sun',
    'Mon',
    'Tu',
    'Wed',
    'Thu',
    'Fri',
    'Sat'
  ];

  void _prevMonth() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));

  void _nextMonth() => setState(() =>
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  void _onDayTap(DateTime day) {
    setState(() {
      if (_selectedStart == null ||
          (_selectedStart != null && _selectedEnd != null)) {
        _selectedStart = day;
        _selectedEnd = null;
      } else {
        if (day.isBefore(_selectedStart!)) {
          _selectedEnd = _selectedStart;
          _selectedStart = day;
        } else {
          _selectedEnd = day;
        }
      }
    });
  }

  bool _isSelected(DateTime day) =>
      (_selectedStart != null && _isSameDay(day, _selectedStart!)) ||
      (_selectedEnd != null && _isSameDay(day, _selectedEnd!));

  bool _isInRange(DateTime day) {
    if (_selectedStart == null || _selectedEnd == null) return false;
    return day.isAfter(_selectedStart!) && day.isBefore(_selectedEnd!);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<List<DateTime?>> _buildWeeks() {
    final firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDay = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startOffset = firstDay.weekday % 7;

    List<DateTime?> days = [];
    for (int i = 0; i < startOffset; i++) {
      days.add(null);
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }
    while (days.length % 7 != 0) {
      days.add(null);
    }

    List<List<DateTime?>> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.sublist(i, i + 7));
    }
    return weeks;
  }

  String _monthName(int month) {
    const names = [
      '',
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return names[month];
  }

  @override
  Widget build(BuildContext context) {
    final weeks = _buildWeeks();

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
                  const Text(
                    'Buscar habitación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3355),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Row(
                      children: [
                        SizedBox(width: 14),
                        Icon(Icons.calendar_month_outlined,
                            color: Colors.white54, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Mijeras kecmase jit las habitatin.',
                          style: TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Mes + flechas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _ArrowBtn(
                                icon: Icons.chevron_left, onTap: _prevMonth),
                            _ArrowBtn(
                                icon: Icons.chevron_left, onTap: _prevMonth),
                          ],
                        ),
                        Text(
                          '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Row(
                          children: [
                            _ArrowBtn(
                                icon: Icons.chevron_right, onTap: _nextMonth),
                            _ArrowBtn(
                                icon: Icons.chevron_right, onTap: _nextMonth),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Días de la semana
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _dayLabels
                          .map((d) => SizedBox(
                                width: 36,
                                child: Text(
                                  d,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF999999),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),

                    // Semanas
                    ...weeks.map((week) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: week.map((day) {
                              if (day == null) {
                                return const SizedBox(width: 36, height: 36);
                              }
                              final selected = _isSelected(day);
                              final inRange = _isInRange(day);
                              final isToday = _isSameDay(day, DateTime.now());

                              return GestureDetector(
                                onTap: () => _onDayTap(day),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.gold
                                        : inRange
                                            ? AppColors.gold.withOpacity(0.15)
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(18),
                                    border: isToday && !selected
                                        ? Border.all(
                                            color: AppColors.gold, width: 1.5)
                                        : null,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: selected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: selected
                                            ? Colors.white
                                            : isToday
                                                ? AppColors.gold
                                                : const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        )),

                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // Adultos
                    _GuestRow(
                      label: 'Adultos',
                      count: _adults,
                      onMinus:
                          _adults > 1 ? () => setState(() => _adults--) : null,
                      onPlus: () => setState(() => _adults++),
                    ),
                    const SizedBox(height: 12),

                    // Niños
                    _GuestRow(
                      label: 'Niños',
                      count: _children,
                      onMinus: _children > 0
                          ? () => setState(() => _children--)
                          : null,
                      onPlus: () => setState(() => _children++),
                    ),

                    const SizedBox(height: 24),

                    // Botón buscar
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Buscar habitación',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20, color: const Color(0xFF999999)),
    );
  }
}

class _GuestRow extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  const _GuestRow({
    required this.label,
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A2E))),
        Row(
          children: [
            _CircleBtn(
              icon: Icons.remove,
              onTap: onMinus,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$count',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            _CircleBtn(
              icon: Icons.add,
              onTap: onPlus,
            ),
          ],
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CircleBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:
              onTap != null ? const Color(0xFFF0EEF8) : const Color(0xFFE0DEE8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon,
            size: 18,
            color:
                onTap != null ? AppColors.backButton : const Color(0xFFBBBBBB)),
      ),
    );
  }
}
