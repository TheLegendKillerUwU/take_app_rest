package com.hotelapp.backend.dto;

import com.hotelapp.backend.model.Habitacion;
import lombok.Builder;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Builder
public class HabitacionResponse {

    private Long id;
    private String numero;
    private String tipo;
    private String descripcion;
    private BigDecimal precio;
    private String imagenUrl;      // ruta relativa: /uploads/habitaciones/xxx.jpg
    private String imagenUrlCompleta; // URL completa: http://IP:8080/uploads/...
    private Boolean disponible;
    private LocalDateTime creadoEn;

    // Convierte la entidad a DTO ya con la URL completa lista para Flutter
    public static HabitacionResponse from(Habitacion h, String baseUrl) {
        String rutaRelativa = h.getImagenUrl();
        String urlCompleta = (rutaRelativa != null && !rutaRelativa.isEmpty())
                ? baseUrl + rutaRelativa
                : null;

        return HabitacionResponse.builder()
                .id(h.getId())
                .numero(h.getNumero())
                .tipo(h.getTipo())
                .descripcion(h.getDescripcion())
                .precio(h.getPrecio())
                .imagenUrl(rutaRelativa)
                .imagenUrlCompleta(urlCompleta)
                .disponible(h.getDisponible())
                .creadoEn(h.getCreadoEn())
                .build();
    }
}
