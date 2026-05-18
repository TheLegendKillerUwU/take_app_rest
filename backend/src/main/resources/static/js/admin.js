// ============================================================
//  HotelApp — admin.js  (versión corregida)
//  Rutas correctas: /api/habitaciones  (NO /api/admin/habitaciones)
// ============================================================

const API_LOGIN        = '/api/auth/login';
const API_HABITACIONES = '/api/habitaciones';   // ← CORREGIDO

// Elementos del DOM
const sectionLogin     = document.getElementById('section-login');
const sectionDashboard = document.getElementById('section-dashboard');
const formLogin        = document.getElementById('form-login');
const btnLogout        = document.getElementById('btn-logout');
const listaHabitaciones = document.getElementById('lista-habitaciones');

// ── 1. COMPROBAR SESIÓN AL CARGAR ──────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (localStorage.getItem('token')) {
        mostrarDashboard();
    } else {
        mostrarLogin();
    }
});

// ── 2. LOGIN ───────────────────────────────────────────────────────────────
formLogin.addEventListener('submit', async (e) => {
    e.preventDefault();

    const correo    = document.getElementById('login-correo').value;
    const contrasena = document.getElementById('login-password').value;

    try {
        const response = await fetch(API_LOGIN, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ correo, contrasena })
        });

        const data = await response.json();

        if (!response.ok) {
            alert(data.error || 'Credenciales incorrectas');
            return;
        }

        localStorage.setItem('token', data.token);
        localStorage.setItem('nombre', data.nombre);
        mostrarDashboard();

    } catch (error) {
        alert('No se pudo conectar al servidor');
    }
});

// ── 3. PUBLICAR HABITACIÓN — flujo en 2 pasos ─────────────────────────────
//   Paso A: POST /api/habitaciones   (JSON con datos)
//   Paso B: POST /api/habitaciones/{id}/imagen  (multipart con el archivo)
// --------------------------------------------------------------------------
document.getElementById('form-habitacion').addEventListener('submit', async (e) => {
    e.preventDefault();

    const token  = localStorage.getItem('token');
    const archivo = document.getElementById('hab-archivo').files[0];

    // Datos en JSON
    const datos = {
        numero:      document.getElementById('hab-numero').value.trim(),
        tipo:        document.getElementById('hab-tipo').value.trim(),
        precio:      parseFloat(document.getElementById('hab-precio').value),
        descripcion: document.getElementById('hab-descripcion').value.trim(),
        disponible:  true
    };

    if (!datos.numero || !datos.tipo || !datos.precio) {
        alert('Número, tipo y precio son obligatorios');
        return;
    }

    try {
        // ── PASO A: crear la habitación con JSON ──────────────────────────
        const resCrear = await fetch(API_HABITACIONES, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify(datos)
        });

        const habCreada = await resCrear.json();

        if (!resCrear.ok) {
            alert(habCreada.error || 'Error al crear la habitación');
            return;
        }

        // ── PASO B: subir la imagen si el usuario seleccionó una ─────────
        if (archivo) {
            const formData = new FormData();
            formData.append('imagen', archivo);  // ← el campo se llama "imagen", no "archivo"

            const resImg = await fetch(`${API_HABITACIONES}/${habCreada.id}/imagen`, {
                method: 'POST',
                headers: {
                    'Authorization': `Bearer ${token}`
                    // NO poner Content-Type aquí — el navegador lo hace solo con FormData
                },
                body: formData
            });

            if (!resImg.ok) {
                alert('Habitación creada pero hubo un error al subir la imagen');
            }
        }

        alert(`¡Habitación ${habCreada.numero} guardada con éxito!`);
        document.getElementById('form-habitacion').reset();
        cargarHabitaciones();

    } catch (error) {
        alert('Error de conexión con el servidor');
        console.error(error);
    }
});

// ── 4. CARGAR LISTA DE HABITACIONES ───────────────────────────────────────
async function cargarHabitaciones() {
    const token = localStorage.getItem('token');
    listaHabitaciones.innerHTML = '<p class="text-gray-500">Cargando habitaciones...</p>';

    try {
        const response = await fetch(API_HABITACIONES, {
            headers: { 'Authorization': `Bearer ${token}` }
        });

        if (!response.ok) throw new Error('No se pudieron cargar las habitaciones');

        const habitaciones = await response.json();

        if (habitaciones.length === 0) {
            listaHabitaciones.innerHTML =
                '<p class="text-gray-500 col-span-2">No hay habitaciones registradas.</p>';
            return;
        }

        listaHabitaciones.innerHTML = habitaciones.map(hab => {
            // imagenUrlCompleta ya viene armada desde la API con la IP del servidor
            const imgUrl = hab.imagenUrlCompleta || 'https://placehold.co/600x400?text=Sin+Foto';

            return `
            <div class="border border-gray-200 rounded-lg overflow-hidden shadow-sm bg-gray-50">
                <img src="${imgUrl}" alt="Habitación ${hab.numero}"
                     class="w-full h-40 object-cover"
                     onerror="this.src='https://placehold.co/600x400?text=Sin+Foto'">
                <div class="p-4">
                    <div class="flex justify-between items-center mb-1">
                        <span class="text-xs font-bold uppercase tracking-wide text-blue-600 bg-blue-100 px-2 py-0.5 rounded">
                            ${hab.tipo}
                        </span>
                        <span class="text-sm font-semibold text-gray-900">Hab. ${hab.numero}</span>
                    </div>
                    <p class="text-gray-600 text-xs line-clamp-2 mt-1">
                        ${hab.descripcion || 'Sin descripción.'}
                    </p>
                    <div class="mt-4 pt-2 border-t border-gray-200 flex justify-between items-center">
                        <span class="text-lg font-bold text-gray-800">
                            $${Number(hab.precio).toFixed(2)}
                        </span>
                        <span class="text-xs font-medium ${hab.disponible ? 'text-green-600' : 'text-red-600'}">
                            ${hab.disponible ? '● Disponible' : '● Ocupada'}
                        </span>
                    </div>
                </div>
            </div>`;
        }).join('');

    } catch (error) {
        listaHabitaciones.innerHTML =
            `<p class="text-red-500 col-span-2">${error.message}</p>`;
    }
}

// ── 5. CONTROL DE PANTALLAS ────────────────────────────────────────────────
function mostrarDashboard() {
    sectionLogin.classList.add('hidden');
    sectionDashboard.classList.remove('hidden');
    cargarHabitaciones();
}

function mostrarLogin() {
    sectionDashboard.classList.add('hidden');
    sectionLogin.classList.remove('hidden');
}

// ── 6. CERRAR SESIÓN ──────────────────────────────────────────────────────
btnLogout.addEventListener('click', () => {
    localStorage.clear();
    mostrarLogin();
});