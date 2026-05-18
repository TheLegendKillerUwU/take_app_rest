// ── ReservaRequest.java ──────────────────────────────────────────────────────
package com.hotelapp.backend.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.time.LocalDate;

@Data
public class ReservaRequest {

    @NotNull(message = "El ID de habitación es obligatorio")
    private Long habitacionId;

    @NotNull(message = "La fecha de entrada es obligatoria")
    @Future(message = "La fecha de entrada debe ser futura")
    private LocalDate fechaEntrada;

    @NotNull(message = "La fecha de salida es obligatoria")
    private LocalDate fechaSalida;

    @Min(value = 1, message = "Debe haber al menos 1 adulto")
    private Integer adultos = 1;

    @Min(value = 0)
    private Integer ninos = 0;
}
