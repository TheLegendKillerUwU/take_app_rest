package com.hotelapp.backend.dto;

import com.hotelapp.backend.model.Reserva;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Builder
public class ReservaResponse {

    private Long id;
    private Long habitacionId;
    private String habitacionNumero;
    private String habitacionTipo;
    private String habitacionImagenUrl;
    private LocalDate fechaEntrada;
    private LocalDate fechaSalida;
    private String estado;
    private BigDecimal total;
    private Integer adultos;
    private Integer ninos;
    private LocalDateTime creadoEn;

    public static ReservaResponse from(Reserva r, String baseUrl) {
        String imagen = r.getHabitacion().getImagenUrl();
        String imagenCompleta = (imagen != null && !imagen.isEmpty())
                ? baseUrl + imagen
                : null;

        return ReservaResponse.builder()
                .id(r.getId())
                .habitacionId(r.getHabitacion().getId())
                .habitacionNumero(r.getHabitacion().getNumero())
                .habitacionTipo(r.getHabitacion().getTipo())
                .habitacionImagenUrl(imagenCompleta)
                .fechaEntrada(r.getFechaEntrada())
                .fechaSalida(r.getFechaSalida())
                .estado(r.getEstado().name())
                .total(r.getTotal())
                .adultos(r.getAdultos())
                .ninos(r.getNinos())
                .creadoEn(r.getCreadoEn())
                .build();
    }
}
