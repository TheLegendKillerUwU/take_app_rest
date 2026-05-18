package com.hotelapp.backend.repository;

import com.hotelapp.backend.model.Habitacion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface HabitacionRepository extends JpaRepository<Habitacion, Long> {

    // Listar solo las disponibles (para la app del usuario)
    List<Habitacion> findByDisponibleTrue();

    // Buscar por tipo (Suite, Sencilla, etc.)
    List<Habitacion> findByTipoIgnoreCase(String tipo);

    // Verificar si un número de habitación ya existe
    boolean existsByNumero(String numero);
}
