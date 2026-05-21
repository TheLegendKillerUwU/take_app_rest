import 'package:flutter/material.dart';
import '../models/habitacion.dart';
import '../services/hotel_api_service.dart';
import '../theme/app_theme.dart';
import 'reservations_screen.dart';

class RoomDetailScreen extends StatefulWidget {
  final Habitacion room;
  const RoomDetailScreen({super.key, required this.room});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final _api = HotelApiService();
  DateTime? _entrada;
  DateTime? _salida;
  int _adultos = 1;
  int _ninos = 0;
  bool _loading = false;

  int get _noches {
    if (_entrada == null || _salida == null) return 0;
    return _salida!.difference(_entrada!).inDays;
  }

  double get _total => _noches <= 0 ? 0 : _noches * widget.room.precio;

  Future<void> _pickEntrada() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day + 1),
      lastDate: DateTime(now.year + 2),
      initialDate: _entrada ?? DateTime(now.year, now.month, now.day + 1),
    );
    if (date == null) return;
    setState(() {
      _entrada = date;
      if (_salida == null || !_salida!.isAfter(date)) {
        _salida = date.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _pickSalida() async {
    final min = (_entrada ?? DateTime.now()).add(const Duration(days: 1));
    final date = await showDatePicker(
      context: context,
      firstDate: min,
      lastDate: DateTime(min.year + 2),
      initialDate: _salida != null && _salida!.isAfter(min) ? _salida! : min,
    );
    if (date != null) setState(() => _salida = date);
  }

  Future<void> _reservar() async {
    if (_entrada == null || _salida == null || _noches <= 0) {
      _snack('Selecciona fecha de entrada y salida.', error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      await _api.crearReserva(
        habitacionId: widget.room.id,
        fechaEntrada: _entrada!,
        fechaSalida: _salida!,
        adultos: _adultos,
        ninos: _ninos,
      );
      if (!mounted) return;
      _snack('Reserva creada. Queda pendiente de confirmación.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (_) => const ReservationsScreen(showBackButton: true)),
      );
    } catch (e) {
      _snack(e.toString(), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String text, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(text),
          backgroundColor: error ? Colors.redAccent : AppColors.gold),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0F7),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: AppColors.headerPurple,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(room.tipo),
              background: room.imagenUrlCompleta == null
                  ? Container(
                      color: const Color(0xFFECE7D5),
                      child: const Center(
                          child: Text('🏨', style: TextStyle(fontSize: 70))))
                  : Image.network(room.imagenUrlCompleta!, fit: BoxFit.cover),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Habitación ${room.numero}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                      Text('\$${room.precio.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                      room.descripcion.isEmpty
                          ? 'Sin descripción.'
                          : room.descripcion,
                      style:
                          const TextStyle(color: Colors.black54, height: 1.4)),
                  const SizedBox(height: 22),
                  _DateButton(
                      label: 'Entrada',
                      value: _format(_entrada),
                      onTap: _pickEntrada),
                  const SizedBox(height: 12),
                  _DateButton(
                      label: 'Salida',
                      value: _format(_salida),
                      onTap: _pickSalida),
                  const SizedBox(height: 18),
                  _Counter(
                      label: 'Adultos',
                      value: _adultos,
                      min: 1,
                      onChanged: (v) => setState(() => _adultos = v)),
                  _Counter(
                      label: 'Niños',
                      value: _ninos,
                      min: 0,
                      onChanged: (v) => setState(() => _ninos = v)),
                  const SizedBox(height: 22),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            _noches <= 0
                                ? 'Selecciona tus fechas'
                                : '$_noches noche(s)',
                            style: const TextStyle(color: Colors.black54)),
                        Text('Total: \$${_total.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _reservar,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline),
                      label:
                          Text(_loading ? 'Reservando...' : 'Reservar ahora'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime? d) => d == null
      ? 'Seleccionar'
      : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _DateButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateButton(
      {required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: AppColors.gold),
            const SizedBox(width: 12),
            Expanded(
                child:
                    Text(label, style: const TextStyle(color: Colors.black54))),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final ValueChanged<int> onChanged;
  const _Counter(
      {required this.label,
      required this.value,
      required this.min,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: AppColors.textDark))),
          IconButton(
              onPressed: value > min ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline)),
          Text('$value',
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          IconButton(
              onPressed: () => onChanged(value + 1),
              icon:
                  const Icon(Icons.add_circle_outline, color: AppColors.gold)),
        ],
      ),
    );
  }
}
