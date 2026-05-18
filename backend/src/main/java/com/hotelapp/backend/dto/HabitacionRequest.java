// ── HabitacionRequest.java ───────────────────────────────────────────────────
package com.hotelapp.backend.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.math.BigDecimal;

@Data
public class HabitacionRequest {

    @NotBlank(message = "El número de habitación es obligatorio")
    private String numero;

    @NotBlank(message = "El tipo es obligatorio")
    private String tipo;

    private String descripcion;

    @NotNull(message = "El precio es obligatorio")
    @DecimalMin(value = "0.01", message = "El precio debe ser mayor a 0")
    private BigDecimal precio;

    private Boolean disponible = true;

    // imagen_url NO viene aquí — se sube por separado como multipart
}
