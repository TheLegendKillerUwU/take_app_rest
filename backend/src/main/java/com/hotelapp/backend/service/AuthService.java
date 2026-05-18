package com.hotelapp.backend.service;

import com.hotelapp.backend.dto.AuthResponse;
import com.hotelapp.backend.dto.LoginRequest;
import com.hotelapp.backend.dto.RegisterRequest;
import com.hotelapp.backend.model.Usuario;
import com.hotelapp.backend.repository.UsuarioRepository;
import com.hotelapp.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    // ── Registro ───────────────────────────────────────────────

    public AuthResponse register(RegisterRequest request) {
        // Verificar si el correo ya existe
        if (usuarioRepository.existsByCorreo(request.getCorreo())) {
            throw new RuntimeException("El correo ya está registrado");
        }

        // Crear el usuario con la contraseña encriptada
        Usuario usuario = Usuario.builder()
                .nombre(request.getNombre())
                .correo(request.getCorreo())
                .contrasena(passwordEncoder.encode(request.getContrasena()))
                .build();

        usuarioRepository.save(usuario);

        String token = jwtService.generateToken(usuario);

        return AuthResponse.builder()
                .token(token)
                .nombre(usuario.getNombre())
                .correo(usuario.getCorreo())
                .mensaje("Registro exitoso")
                .build();
    }

    // ── Login ──────────────────────────────────────────────────

    public AuthResponse login(LoginRequest request) {
        // Spring Security verifica correo y contraseña automáticamente
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getCorreo(),
                        request.getContrasena()
                )
        );

        Usuario usuario = usuarioRepository.findByCorreo(request.getCorreo())
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        String token = jwtService.generateToken(usuario);

        return AuthResponse.builder()
                .token(token)
                .nombre(usuario.getNombre())
                .correo(usuario.getCorreo())
                .mensaje("Inicio de sesión exitoso")
                .build();
    }
}