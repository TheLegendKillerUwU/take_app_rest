package com.hotelapp.backend.service;

import com.hotelapp.backend.dto.HabitacionRequest;
import com.hotelapp.backend.dto.HabitacionResponse;
import com.hotelapp.backend.model.Habitacion;
import com.hotelapp.backend.repository.HabitacionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;

@Service
@RequiredArgsConstructor
public class HabitacionService {

    private final HabitacionRepository habitacionRepository;
    private final StorageService storageService;

    // URL base del servidor — se inyecta desde application.properties
    // Ej: http://192.168.8.73:8080
    @Value("${app.base-url}")
    private String baseUrl;

    // ── Listar todas (admin) ───────────────────────────────────────────────────

    public List<HabitacionResponse> listarTodas() {
        return habitacionRepository.findAll()
                .stream()
                .map(h -> HabitacionResponse.from(h, baseUrl))
                .toList();
    }

    // ── Listar solo disponibles (app usuario) ─────────────────────────────────

    public List<HabitacionResponse> listarDisponibles() {
        return habitacionRepository.findByDisponibleTrue()
                .stream()
                .map(h -> HabitacionResponse.from(h, baseUrl))
                .toList();
    }

    // ── Obtener una por ID ────────────────────────────────────────────────────

    public HabitacionResponse obtenerPorId(Long id) {
        Habitacion h = habitacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));
        return HabitacionResponse.from(h, baseUrl);
    }

    // ── Crear habitación (sin imagen) ─────────────────────────────────────────

    public HabitacionResponse crear(HabitacionRequest request) {
        if (habitacionRepository.existsByNumero(request.getNumero())) {
            throw new RuntimeException("Ya existe una habitación con el número: " + request.getNumero());
        }

        Habitacion habitacion = Habitacion.builder()
                .numero(request.getNumero())
                .tipo(request.getTipo())
                .descripcion(request.getDescripcion())
                .precio(request.getPrecio())
                .disponible(request.getDisponible() != null ? request.getDisponible() : true)
                .build();

        return HabitacionResponse.from(habitacionRepository.save(habitacion), baseUrl);
    }

    // ── Subir / actualizar imagen de una habitación ───────────────────────────

    public HabitacionResponse subirImagen(Long id, MultipartFile imagen) throws IOException {
        Habitacion habitacion = habitacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));

        // Si ya tenía imagen, borra la anterior del disco
        if (habitacion.getImagenUrl() != null) {
            storageService.eliminarImagen(habitacion.getImagenUrl());
        }

        // Guarda la nueva imagen y obtiene la ruta
        String rutaNueva = storageService.guardarImagen(imagen, "habitaciones");
        habitacion.setImagenUrl(rutaNueva);

        return HabitacionResponse.from(habitacionRepository.save(habitacion), baseUrl);
    }

    // ── Actualizar datos (sin cambiar imagen) ─────────────────────────────────

    public HabitacionResponse actualizar(Long id, HabitacionRequest request) {
        Habitacion habitacion = habitacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));

        habitacion.setNumero(request.getNumero());
        habitacion.setTipo(request.getTipo());
        habitacion.setDescripcion(request.getDescripcion());
        habitacion.setPrecio(request.getPrecio());
        if (request.getDisponible() != null) {
            habitacion.setDisponible(request.getDisponible());
        }

        return HabitacionResponse.from(habitacionRepository.save(habitacion), baseUrl);
    }

    // ── Eliminar ──────────────────────────────────────────────────────────────

    public void eliminar(Long id) {
        Habitacion habitacion = habitacionRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Habitación no encontrada"));

        // Borra la imagen del disco también
        if (habitacion.getImagenUrl() != null) {
            storageService.eliminarImagen(habitacion.getImagenUrl());
        }

        habitacionRepository.delete(habitacion);
    }
}
