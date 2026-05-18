package com.hotelapp.backend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@Service
public class StorageService {

    // Carpeta base donde se guardan las imágenes en el servidor
    // Configurada en application.properties como: storage.upload-dir=uploads
    @Value("${storage.upload-dir:uploads}")
    private String uploadDir;

    /**
     * Guarda un archivo en disco y retorna la ruta relativa.
     *
     * @param archivo   El archivo recibido del cliente
     * @param subcarpeta  Ej: "habitaciones" → guardará en uploads/habitaciones/
     * @return  Ruta relativa lista para guardar en BD: /uploads/habitaciones/uuid.jpg
     */
    public String guardarImagen(MultipartFile archivo, String subcarpeta) throws IOException {

        // 1. Validar que sea una imagen
        String contentType = archivo.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Solo se permiten archivos de imagen");
        }

        // 2. Obtener extensión del archivo original
        String nombreOriginal = archivo.getOriginalFilename();
        String extension = "";
        if (nombreOriginal != null && nombreOriginal.contains(".")) {
            extension = nombreOriginal.substring(nombreOriginal.lastIndexOf("."));
        }

        // 3. Generar nombre único con UUID para evitar colisiones
        String nombreUnico = UUID.randomUUID().toString() + extension;

        // 4. Crear la carpeta si no existe
        // Ej: uploads/habitaciones/
        Path carpeta = Paths.get(uploadDir, subcarpeta);
        Files.createDirectories(carpeta);

        // 5. Guardar el archivo en disco
        Path destino = carpeta.resolve(nombreUnico);
        Files.copy(archivo.getInputStream(), destino, StandardCopyOption.REPLACE_EXISTING);

        // 6. Retornar la ruta relativa que se guarda en la BD
        // Ej: /uploads/habitaciones/550e8400-uuid.jpg
        return "/" + uploadDir + "/" + subcarpeta + "/" + nombreUnico;
    }

    /**
     * Elimina un archivo del disco dado su ruta relativa.
     * Se usa cuando se reemplaza la imagen de una habitación.
     *
     * @param rutaRelativa  La ruta guardada en BD: /uploads/habitaciones/uuid.jpg
     */
    public void eliminarImagen(String rutaRelativa) {
        if (rutaRelativa == null || rutaRelativa.isBlank()) return;
        try {
            // Quita el "/" inicial para construir el Path local
            Path archivo = Paths.get(rutaRelativa.substring(1));
            Files.deleteIfExists(archivo);
        } catch (IOException e) {
            // Si no se puede borrar el archivo, solo lo logueamos — no es un error crítico
            System.err.println("No se pudo eliminar imagen: " + rutaRelativa);
        }
    }
}
