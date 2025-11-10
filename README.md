# proyecto_final

A new Flutter project.

## Getting Started

## Proyecto MetroBox — Documentación de `lib/`

Guía rápida y completa de los archivos dentro de `lib/`, cómo se conectan entre sí y qué hace cada uno.

### Rutas y arranque
- `lib/main.dart`
	- Inicializa Firebase (`Firebase.initializeApp` usando `firebase_options.dart`).
	- Define rutas: `/login`, `/registrar`, `/reset_password`, `/perfil`, `/principal`.
	- Aplica tema base y desactiva el banner de debug.
	- (Antes) Se tenía un servicio de logging y captura global; a solicitud del equipo, el guardado de errores se deshabilitó.

### Servicios (capa de datos y auth)
- `lib/services/auth_service.dart`
	- Servicio singleton envuelto sobre `FirebaseAuth`.
	- Métodos: `signIn`, `register`, `signOut`, `sendPasswordReset`, `changePassword` (con reautenticación), `authStateChanges` y `currentUser`.
	- Errores comunes a manejar: `user-not-found`, `wrong-password`, `email-already-in-use`, `weak-password`, `requires-recent-login`.

- `lib/services/firebase_services.dart`
	- Acceso a Firestore (colección `user`).
	- Funciones: `getUser(context)` (lista de usuarios normalizada), `addUser`, `updateUser`, `updateUserLoginDate`, `deleteUser`.
	- Notas: `getUser` devuelve cada usuario como `Map` con claves: `name`, `uid`, `email`, `isadmin`, `id_carnet` (int), `cedula`, `date_login` (DateTime).

### UI — Páginas y widgets
- `lib/Page_Ui/pagina_login/login.dart`
	- Pantalla de login. Incluye:
		- `UsernameField` (valida correo institucional), `PasswordField` (widget separado) y botón `IniciarSesion` (widget separado).
		- Imagen de usuario con fallback a ícono si falla la carga.
		- Botón “Registrarse” → navega a `/registrar`.

	- `lib/Page_Ui/reporte_dashboard/` — Dashboard y Reportes
		- `dashboard_page.dart`: métricas, próximos a entregar y progreso por proyecto.
		- `reportes_page.dart`: tabla filtrable (por ID/nombre, fecha y estado) y exportación a CSV.
		- `proyecto_repository.dart`: acceso y filtrado de datos de proyectos, cálculo de KPIs.
		- `models.dart`: modelos `Proyecto`, `ProyectoFilter`, `DashboardStats`.
		- `widgets.dart`: UI reutilizable (barra de filtros, tarjetas de resumen y tabla).


- `lib/Page_Ui/pagina_login/widget_password.dart`
	- Campo de contraseña con toggle de visibilidad y validaciones básicas.
	- Link “¿Olvidaste tu contraseña?” → navega a `/reset_password`.

- `lib/Page_Ui/pagina_login/widget_iniciar_sesion.dart`
	- Botón de acción para iniciar sesión.
	- Usa `AuthService().signIn(email, password)`.
	- Tras login: consulta Firestore (`getUser`), detecta si es admin, actualiza `date_login` y navega a `/principal`.

- `lib/Page_Ui/pagina_crear_cuenta/registrar_usuario.dart`
	- Formulario de registro con validaciones de nombre, cédula (6–8 dígitos), email institucional, contraseña (>=8), y carnet (11 dígitos).
	- Al registrar: comprueba duplicados en Firestore; crea usuario en Auth y documento en `user` (marca `isadmin=true` si el email es unimet.edu.ve).
	- Nota: al verificar duplicados, la clave del carnet debe ser `id_carnet` (en `getUser`), no `carnet`.

- `lib/Page_Ui/validator/validar_email.dart`
	- Helpers de validación de correo institucional: `validateUnimetEmail` y `isUnimetEmail`.

- `lib/Page_Ui/pagina_login/reset_password/olvidecontrasena.dart`
	- Pantalla para restablecer contraseña. Usa `AuthService().sendPasswordReset(email)`.
	- UI con validaciones suaves y navegación de regreso.

- `lib/Page_Ui/pagina_principal/pagina_principal.dart`
	- Home con `Drawer` (muestra el email del usuario autenticado) y header con menú.
	- Atajos a secciones (Proyectos, Calendario, Ajustes/Perfil) y opción de cerrar sesión.

- `lib/Page_Ui/perfil_usuario/usuario.dart`
	- Perfil del usuario: muestra nombre, correo, carnet, cédula y última conexión.
	- Permite editar y guarda con `updateUser`; carga datos buscando por el email del usuario autenticado.

### Archivos generados
- `lib/firebase_options.dart`
	- Generado por `flutterfire configure`. No editar manualmente.


## Sugerencias prácticas

- Usa `uid` como clave principal para documentos en `user` y evita buscar por `email` cuando sea posible.
- Muestra mensajes de error amigables (SnackBar) y valida entradas (cédula/carnet numéricos).
- Para evitar spam al enviar correos, configura SPF/DKIM/DMARC si usas dominio propio.

## Ejecutar el proyecto (resumen)

1) Instala dependencias: `flutter pub get`.
2) Configura Firebase y `firebase_options.dart` (via `flutterfire configure`).
3) Corre la app en tu dispositivo/emulador. 
