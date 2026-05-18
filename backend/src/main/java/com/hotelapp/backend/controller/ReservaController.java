package com.hotelapp.backend.controller;

import com.hotelapp.backend.dto.ReservaRequest;
import com.hotelapp.backend.dto.ReservaResponse;
import com.hotelapp.backend.service.ReservaService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reservas")
@RequiredArgsConstructor
@Tag(name = "Reservas", description = "Gestión de reservas de habitaciones")
@SecurityRequirement(name = "BearerAuth")
public class ReservaController {

    private final ReservaService reservaService;

    // ── POST /api/reservas ────────────────────────────────────────────────────
    // El usuario autenticado crea su propia reserva
    @PostMapping
    @Operation(summary = "Crear reserva", description = "El usuario autenticado crea una reserva para una habitación")
    public ResponseEntity<?> crear(
            @Valid @RequestBody ReservaRequest request,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            ReservaResponse response = reservaService.crear(request, userDetails.getUsername());
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ── GET /api/reservas/mis-reservas ────────────────────────────────────────
    // El usuario ve solo sus propias reservas
    @GetMapping("/mis-reservas")
    @Operation(summary = "Ver mis reservas", description = "Retorna todas las reservas del usuario autenticado")
    public ResponseEntity<List<ReservaResponse>> misReservas(
            @AuthenticationPrincipal UserDetails userDetails) {
        return ResponseEntity.ok(reservaService.misReservas(userDetails.getUsername()));
    }

    // ── PATCH /api/reservas/{id}/cancelar ─────────────────────────────────────
    @PatchMapping("/{id}/cancelar")
    @Operation(summary = "Cancelar reserva", description = "El usuario cancela una de sus reservas")
    public ResponseEntity<?> cancelar(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetails userDetails) {
        try {
            return ResponseEntity.ok(reservaService.cancelar(id, userDetails.getUsername()));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    // ── GET /api/reservas (solo ADMIN) ────────────────────────────────────────
    @GetMapping
    @Operation(summary = "Listar todas las reservas (admin)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<ReservaResponse>> listarTodas() {
        return ResponseEntity.ok(reservaService.listarTodas());
    }

    // ── PATCH /api/reservas/{id}/confirmar (solo ADMIN) ───────────────────────
    @PatchMapping("/{id}/confirmar")
    @Operation(summary = "Confirmar reserva (admin)")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<?> confirmar(@PathVariable Long id) {
        try {
            return ResponseEntity.ok(reservaService.confirmar(id));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
}
