# 🎮 Plan de Implementación: GameShop (Tienda de Videojuegos)

> **Nota preliminar:** *Antigravity* no es un entorno de desarrollo reconocido para Flutter. Se recomienda utilizar **VS Code** como IDE principal, complementado con las herramientas oficiales de Flutter y Firebase. Este plan está estructurado para evitar código hasta que el diseño y la arquitectura sean validados.

---

## 🛠️ 1. Herramientas Requeridas

| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| **SDK & Lenguaje** | Flutter SDK + Dart 3.x | Framework multiplataforma y lenguaje base |
| **IDE** | VS Code | Desarrollo, depuración y gestión de paquetes |
| **Extensiones VS Code** | Flutter, Dart, Firebase, Error Lens, Pretty Diff | Autocompletado, linting, integración con Firebase |
| **Backend & Cloud** | Firebase Console + Firebase CLI | Autenticación, Firestore, Hosting, Analytics |
| **Emuladores/Dispositivos** | Android Emulator, iOS Simulator, Chrome (Web) | Pruebas multiplataforma |
| **Diseño UI/UX** | Figma o Penpot | Wireframes, prototipos interactivos, sistema de diseño |
| **Control de Versiones** | Git + GitHub/GitLab | Historial, colaboración, CI/CD básico |
| **Herramientas de Depuración** | Flutter DevTools, Chrome DevTools | Rendimiento, red, estado de memoria |

---

## 📦 2. Dependencias Clave (`pubspec.yaml`)

*Nota: Estas dependencias se instalarán en fases específicas. No incluiré código de instalación, solo la lista de referencia.*

| Dependencia | Versión Sugerida | Función |
|-------------|------------------|---------|
| `firebase_core` | `^2.x` | Inicialización de Firebase |
| `firebase_auth` | `^4.x` | Autenticación email/password, sesiones |
| `cloud_firestore` | `^4.x` | Base de datos NoSQL en tiempo real |
| `provider` | `^6.x` | Gestión de estado reactiva |
| `go_router` | `^13.x` | Enrutamiento avanzado + protección de rutas |
| `cached_network_image` | `^3.x` | Carga y caché de portadas de juegos |
| `intl` | `^0.19.x` | Formato de fechas, monedas y localización |
| `uuid` | `^4.x` | Generación de IDs para carritos/ordenes (si no se usa auto-ID de Firestore) |
| `flutter_secure_storage` | `^9.x` | Almacenamiento seguro de tokens/refrescos |
| `http` | `^1.x` | Consumo de APIs externas (pasarelas de pago, catálogos) |
| `sentry_flutter` o `firebase_crashlytics` | `^7.x` | Monitoreo de errores en producción |

---

## 🎨 3. Principios de UI/UX para GameShop

- **Tema Visual:** Modo oscuro por defecto con acentos neón (cian/magenta) para resaltar botones y precios. Fondo degradado sutil para evitar fatiga visual.
- **Tipografía:** `Inter` o `Poppins` para legibilidad en listas; `Orbitron` o `Rajdhani` solo para títulos/precios.
- **Jerarquía de Componentes:**
  - Tarjetas de juego con portada, título, precio, rating y badge de oferta.
  - Barra de búsqueda persistente + filtros (género, plataforma, precio).
  - Navegación inferior: `Inicio`, `Buscar`, `Carrito`, `Perfil`.
- **Feedback y Microinteracciones:** Estados de carga (`shimmer`), transiciones suaves entre pantallas, toast de confirmación al agregar al carrito.
- **Accesibilidad:** Contraste mínimo 4.5:1, tamaños de fuente escalables, etiquetas semánticas para lectores de pantalla.
- **Responsividad:** Grid adaptativo (2 columnas en móvil, 3-4 en tablet/web), márgenes dinámicos según `MediaQuery`.

---

## 🏗️ 4. Arquitectura y Estructura del Proyecto

```
lib/
├── main.dart                  # Punto de entrada + MultiProvider + Tema
├── core/
│   ├── theme/                 # Paleta, tipografías, estilos globales
│   ├── utils/                 # Validadores, formateadores, constantes
│   └── errors/                # Manejo de excepciones personalizadas
├── data/
│   ├── repositories/          # Lógica de acceso a Firestore/Auth
│   └── models/                # Clases serializables (User, Game, CartItem)
├── providers/
│   ├── auth_provider.dart
│   ├── cart_provider.dart
│   └── games_provider.dart
├── presentation/
│   ├── screens/               # Pantallas completas
│   ├── widgets/               # Componentes reutilizables
│   └── navigation/            # Configuración de rutas
└── services/
    └── firebase_service.dart  # Inicialización y configuración de Firebase
```

*Patrón recomendado:* **Feature-First + Provider-Centric**. Cada funcionalidad (Auth, Catálogo, Carrito) se encapsula con su provider, repositorio y vistas asociadas.

---

## 📋 5. Procedimiento Paso a Paso

### 🔹 Fase 1: Configuración del Entorno y Proyecto
1. Instalar Flutter SDK y configurar rutas de sistema.
2. Configurar VS Code con extensiones oficiales y validar con `flutter doctor`.
3. Crear proyecto: `flutter create gameshop`.
4. Crear proyecto en Firebase Console, habilitar **Authentication** (Email/Password) y **Firestore**.
5. Ejecutar `flutterfire configure` para vincular el proyecto Flutter con Firebase (genera `firebase_options.dart`).
6. Inicializar repositorio Git y crear rama `develop`.

### 🔹 Fase 2: Arquitectura y Base del Sistema
1. Definir estructura de carpetas según el esquema anterior.
2. Configurar `main.dart` con `runApp` envuelto en `MultiProvider`.
3. Implementar sistema de rutas con `go_router` (rutas nombradas para `/login`, `/home`, `/cart`, `/profile`).
4. Crear clases modelo base (`Game`, `User`, `CartItem`) con métodos `fromJson`/`toJson`.
5. Configurar tema global (colores, tipografía, modo oscuro).

### 🔹 Fase 3: UI/UX y Componentes Base
1. Disear wireframes en Figma: Login, Catálogo, Detalle, Carrito, Perfil.
2. Implementar widgets reutilizables: `PrimaryButton`, `TextFieldCustom`, `LoadingOverlay`, `EmptyState`, `GameCard`.
3. Configurar `BottomNavigationBar` con iconos personalizados y estado activo/inactivo.
4. Validar responsividad en 3 tamaños de pantalla (móvil, tablet, web).
5. Implementar transiciones de pantalla y estados de error/vacío.

### 🔹 Fase 4: Autenticación y Seguridad
1. Crear `AuthService` para interactuar con `firebase_auth`.
2. Implementar lógica de registro/login con validación de email y contraseña (mínimo 8 caracteres, mayúscula, número).
3. Manejar estados de sesión: `signedIn`, `signedOut`, `loading`, `error`.
4. Configurar guard de rutas: redirigir a `/login` si no hay usuario autenticado, bloquear acceso a `/login` si ya está autenticado.
5. Implementar cierre de sesión seguro y limpieza de estado local.

### 🔹 Fase 5: Base de Datos Firestore y Sincronización
1. Diseñar estructura de colecciones:
   - `games/`: `id`, `title`, `price`, `platform`, `genre`, `coverUrl`, `rating`
   - `users/{uid}/cart/`: `gameId`, `quantity`, `addedAt`
   - `users/{uid}/orders/`: histórico de compras (futuro)
2. Crear `FirestoreService` con métodos genéricos: `fetchGames()`, `addToCart()`, `removeFromCart()`, `getCart()`.
3. Implementar paginación o carga por lotes (`limit` + `startAfter`) para el catálogo.
4. Configurar reglas de seguridad iniciales en Firestore (solo lectura pública para `games`, acceso restringido por `uid` para `cart`/`orders`).
5. Habilitar caché offline de Firestore para mejorar experiencia sin conexión.

### 🔹 Fase 6: Gestión de Estado con Provider
1. Crear `AuthProvider`: estado de usuario, métodos `login()`, `register()`, `logout()`, validación de formularios en tiempo real.
2. Crear `CartProvider`: lista de items, métodos `add()`, `remove()`, `clear()`, cálculo de total, sincronización con Firestore.
3. Crear `GamesProvider`: carga de catálogo, filtros, búsqueda, manejo de estados `loading`, `success`, `error`.
4. Conectar UI con `context.watch`/`context.read` y `Consumer` donde sea necesario.
5. Implementar manejo centralizado de errores y mensajes de usuario.

### 🔹 Fase 7: Funcionalidades Clave y Flujo Completo
1. Integrar pantalla de autenticación con `AuthProvider`.
2. Conectar catálogo con `GamesProvider` + `FirestoreService`.
3. Implementar vista de detalle de juego con botón "Agregar al carrito".
4. Desarrollar pantalla de carrito con cantidades editables, resumen y botón "Proceder al pago" (simulado inicialmente).
5. Crear perfil de usuario con datos de cuenta, historial y cierre de sesión.
6. Validar flujo completo: Registro → Login → Navegar → Agregar al carrito → Ver perfil → Logout.

### 🔹 Fase 8: Pruebas, Optimización y Despliegue
1. Ejecutar pruebas unitarias para providers y validadores.
2. Realizar pruebas de integración en emuladores y dispositivo físico.
3. Optimizar imágenes (`cached_network_image`), reducir rebuilds innecesarios con `const` y `Provider.of(context, listen: false)`.
4. Analizar rendimiento con Flutter DevTools (FPS, memoria, red).
5. Configurar íconos, splash screen y metadatos para cada plataforma.
6. Generar builds de producción (`flutter build apk`, `ipa`, `web`).
7. Desplegar web en Firebase Hosting. Preparar paquetes para Play Store/App Store.
8. Documentar arquitectura, decisiones técnicas y guía de contribución.

---

## 📌 Próximos Pasos

1. ✅ Revisar y aprobar este plan de implementación.
2. 📐 Validar wireframes y paleta de colores antes de codificar.
3. 🔐 Definir reglas de seguridad de Firestore y política de contraseñas.
4. 🛒 Decidir integración de pagos real (Stripe, MercadoPago, simulado).
5. 💻 Cuando el plan sea aprobado, procederé a entregar **código paso a paso** alineado con cada fase, comenzando por configuración de `pubspec.yaml`, `main.dart`, y el flujo de autenticación.

¿Deseas ajustar alguna fase, agregar funcionalidades (reseñas, wishlist, notificaciones push) o definir la política de pagos antes de avanzar a la implementación con código?
