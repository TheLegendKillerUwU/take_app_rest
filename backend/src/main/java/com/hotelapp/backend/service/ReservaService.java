package com.hotelapp.backend.service;

import com.hotelapp.backend.dto.ReservaRequest;
import com.hotelapp.backend.dto.ReservaResponse;
import com.hotelapp.backend.model.Habitacion;
import com.hotelapp.backend.model.Reserva;
import com.hotelapp.backend.model.Usuario;
import com.hotelapp.backend.repository.HabitacionRepository;
import com.hotelapp.backend.repository.ReservaRepository;
import com.hotelapp.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReservaService {

    private final ReservaRepository reservaRepository;
    private final HabitacionRepository habitacionRepository;
    private final UsuarioRepository usuarioRepository;

    @Value("${app.base-url}")
    private String baseUrl;

    // ── Crear reserva ─────────────────────────────────────────────────────────

    public ReservaResponse crear(ReservaRequest request, String correoUsuario) {

        // 1. Buscar usuario autenticado
        Usuario usuario = usuarioRepository.findByCorreo(correoUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // 2. Buscar habitación
        Habitacion habitacion = habitacionRepository.findById(request.getHabitacionId())
                .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));

        // 3. Verificar disponibilidad
        if (!habitacion.getDisponible()) {
            throw new RuntimeException("La habitación no está disponible");
        }

        // 4. Verificar conflicto de fechas
        if (request.getFechaSalida().isBefore(request.getFechaEntrada()) ||
            request.getFechaSalida().isEqual(request.getFechaEntrada())) {
            throw new RuntimeException("La fecha de salida debe ser posterior a la de entrada");
        }

        if (reservaRepository.existeConflictoFechas(
                habitacion.getId(),
                request.getFechaEntrada(),
                request.getFechaSalida())) {
            throw new RuntimeException("La habitación ya está reservada en esas fechas");
        }

        // 5. Calcular total (precio por noche × número de noches)
        long noches = ChronoUnit.DAYS.between(request.getFechaEntrada(), request.getFechaSalida());
        BigDecimal total = habitacion.getPrecio().multiply(BigDecimal.valueOf(noches));

        // 6. Crear y guardar la reserva
        Reserva reserva = Reserva.builder()
                .usuario(usuario)
                .habitacion(habitacion)
                .fechaEntrada(request.getFechaEntrada())
                .fechaSalida(request.getFechaSalida())
                .adultos(request.getAdultos())
                .ninos(request.getNinos())
                .total(total)
                .estado(Reserva.Estado.PENDIENTE)
                .build();

        return ReservaResponse.from(reservaRepository.save(reserva), baseUrl);
    }

    // ── Listar reservas del usuario autenticado ───────────────────────────────

    public List<ReservaResponse> misReservas(String correoUsuario) {
        Usuario usuario = usuarioRepository.findByCorreo(correoUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        return reservaRepository.findByUsuarioIdOrderByCreadoEnDesc(usuario.getId())
                .stream()
                .map(r -> ReservaResponse.from(r, baseUrl))
                .toList();
    }

    // ── Cancelar reserva ──────────────────────────────────────────────────────

    public ReservaResponse cancelar(Long id, String correoUsuario) {
        Reserva reserva = reservaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        // Solo puede cancelar el dueño de la reserva
        if (!reserva.getUsuario().getCorreo().equals(correoUsuario)) {
            throw new RuntimeException("No tienes permiso para cancelar esta reserva");
        }

        if (reserva.getEstado() == Reserva.Estado.CANCELADA) {
            throw new RuntimeException("La reserva ya está cancelada");
        }

        reserva.setEstado(Reserva.Estado.CANCELADA);
        return ReservaResponse.from(reservaRepository.save(reserva), baseUrl);
    }

    // ── Listar todas (solo ADMIN) ─────────────────────────────────────────────

    public List<ReservaResponse> listarTodas() {
        return reservaRepository.findAll()
                .stream()
                .map(r -> ReservaResponse.from(r, baseUrl))
                .toList();
    }

    // ── Confirmar reserva (solo ADMIN) ────────────────────────────────────────

    public ReservaResponse confirmar(Long id) {
        Reserva reserva = reservaRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Reserva no encontrada"));

        reserva.setEstado(Reserva.Estado.CONFIRMADA);
        return ReservaResponse.from(reservaRepository.save(reserva), baseUrl);
    }
}
