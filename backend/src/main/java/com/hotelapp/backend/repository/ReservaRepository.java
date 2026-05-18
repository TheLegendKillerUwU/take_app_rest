package com.hotelapp.backend.repository;

import com.hotelapp.backend.model.Reserva;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

public interface ReservaRepository extends JpaRepository<Reserva, Long> {

    // Reservas de un usuario específico
    List<Reserva> findByUsuarioIdOrderByCreadoEnDesc(Long usuarioId);

    // Reservas por estado (PENDIENTE, CONFIRMADA, CANCELADA)
    List<Reserva> findByUsuarioIdAndEstado(Long usuarioId, Reserva.Estado estado);

    // Verificar si una habitación está ocupada en un rango de fechas
    // (para evitar reservas duplicadas)
    @Query("""
        SELECT COUNT(r) > 0 FROM Reserva r
        WHERE r.habitacion.id = :habitacionId
        AND r.estado != 'CANCELADA'
        AND r.fechaEntrada < :fechaSalida
        AND r.fechaSalida > :fechaEntrada
    """)
    boolean existeConflictoFechas(
        @Param("habitacionId") Long habitacionId,
        @Param("fechaEntrada") LocalDate fechaEntrada,
        @Param("fechaSalida") LocalDate fechaSalida
    );
}
