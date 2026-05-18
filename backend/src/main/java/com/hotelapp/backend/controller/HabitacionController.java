package com.hotelapp.backend.controller;

import com.hotelapp.backend.dto.HabitacionRequest;
import com.hotelapp.backend.dto.HabitacionResponse;
import com.hotelapp.backend.service.HabitacionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/habitaciones")
@RequiredArgsConstructor
@Tag(name = "Habitaciones", description = "Gestión de habitaciones del hotel")
@SecurityRequirement(name = "BearerAuth")
public class HabitacionController {

    private final HabitacionService habitacionService;

    // ── GET /api/habitaciones/disponibles ─────────────────────────────────────
    // Pública para la app del usuario (requiere token pero no rol especial)
    @GetMapping("/disponibles")
    @Operation(summary = "Listar habitaciones disponibles", description = "Retorna las habitaciones disponibles para reservar")
    public ResponseEntity<List<HabitacionResponse>> listarDisponibles() {
        return ResponseEntity.ok(habitacionService.listarDisponibles());
    }

    // ── GET /api/habitaciones ─────────────────────────────────────────────────
    // Solo ADMIN — ve todas incluyendo no disponibles
    @GetMapping
    @Operation(summary = "Listar todas las habitaciones (admin)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<HabitacionResponse>> listarTodas() {
        return ResponseEntity.ok(habitacionService.listarTodas());
    }

    // ── GET /api/habitaciones/{id} ────────────────────────────────────────────
    @GetMapping("/{id}")
    @Operation(summary = "Obtener habitación por ID")
    public ResponseEntity<HabitacionResponse> obtenerPorId(@PathVariable Long id) {
        return ResponseEntity.ok(habitacionService.obtenerPorId(id));
    }

    // ── POST /api/habitaciones ────────────────────────────────────────────────
    // Solo ADMIN — crea una habitación sin imagen
    @PostMapping
    @Operation(summary = "Crear habitación (admin)", description = "Crea una habitación. La imagen se sube por separado con /imagen")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<HabitacionResponse> crear(@Valid @RequestBody HabitacionRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(habitacionService.crear(request));
    }

    // ── POST /api/habitaciones/{id}/imagen ────────────────────────────────────
    // Solo ADMIN — sube o reemplaza la imagen de una habitación
    @PostMapping(value = "/{id}/imagen", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(
        summary = "Subir imagen de habitación (admin)",
        description = "Sube una imagen al servidor. Se guarda en /uploads/habitaciones/ y la ruta queda en la BD"
    )
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> subirImagen(
            @PathVariable Long id,
            @RequestParam("imagen") MultipartFile imagen) {
        try {
            HabitacionResponse response = habitacionService.subirImagen(id, imagen);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", "Error al guardar la imagen en el servidor"));
        }
    }

    // ── PUT /api/habitaciones/{id} ────────────────────────────────────────────
    @PutMapping("/{id}")
    @Operation(summary = "Actualizar habitación (admin)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<HabitacionResponse> actualizar(
            @PathVariable Long id,
            @Valid @RequestBody HabitacionRequest request) {
        return ResponseEntity.ok(habitacionService.actualizar(id, request));
    }

    // ── DELETE /api/habitaciones/{id} ─────────────────────────────────────────
    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar habitación (admin)", description = "Elimina la habitación y su imagen del servidor")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> eliminar(@PathVariable Long id) {
        habitacionService.eliminar(id);
        return ResponseEntity.noContent().build();
    }
}
