# 📋 PLAN DE IMPLEMENTACIÓN DETALLADO: GAME SHOP 

Este documento consolida el plan original con los elementos solicitados: **estructura de carpetas completa**, **dependencias organizadas** y **énfasis en Provider**. No incluye código de aplicación; está diseñado para ser revisado, aprobado y ejecutado módulo por módulo.

---

## 1. 🔧 CONFIGURACIÓN DEL PROYECTO

### 1.1. Firebase Console
1. **Crear Proyecto**: `Agregar proyecto` → Nombre: `GameShop`.
2. **Google Analytics**: Desmarcar explícitamente `Habilitar Google Analytics para este proyecto`.
3. **Firestore Database**: `Crear base de datos` → Modo de producción/estándar → Ubicación regional recomendada (`eur3` o `us-central`) → Reglas iniciales: `Deny all`.
4. **Authentication**: `Sign-in method` → Habilitar `Correo electrónico/Contraseña` → Configurar plantillas de email (ES/EN) para recuperación.

### 1.2. Conexión con Flutter
1. Instalar Firebase CLI: `npm install -g firebase-tools`.
2. Ejecutar `flutterfire configure` en la raíz del proyecto para generar `firebase_options.dart` y archivos nativos.
3. Inicializar en `main()`: `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`

---

## 2. 🏗️ ARQUITECTURA DEL PROYECTO (ESTRUCTURA COMPLETA)

Se adopta **MVVM ligero con separación por features**, priorizando mantenibilidad, testabilidad y escalabilidad.

```
game_shop/
├── android/                          # Configuración nativa Android
├── ios/                              # Configuración nativa iOS
├── lib/
│   ├── main.dart                     # Entry point, inicialización Firebase, MultiProvider, MaterialApp.router
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_constants.dart    # Keys, timeouts, límites de input, valores por defecto
│   │   │   ├── app_routes.dart       # Constantes de rutas nombradas
│   │   │   └── app_colors.dart       # Paleta oficial (primary, secondary, accent, surface, error, logout)
│   │   ├── errors/
│   │   │   ├── exceptions.dart       # AuthException, FirestoreException, NetworkException, ValidationException
│   │   │   └── failures.dart         # Clases de error estructuradas para manejo centralizado
│   │   ├── network/
│   │   │   └── connectivity_service.dart # Listener de estado online/offline
│   │   ├── router/
│   │   │   ├── app_router.dart       # Configuración GoRouter + AuthGuard + RouteObserver
│   │   │   └── route_guards.dart     # Middleware de autenticación y validación de rol
│   │   ├── theme/
│   │   │   ├── app_theme.dart        # ThemeData light/dark, elevación, bordes, spacing
│   │   │   └── typography.dart       # Escala tipográfica (Poppins/Inter), pesos, interlineado
│   │   └── utils/
│   │       ├── formatters.dart       # Moneda, fechas, máscaras
│   │       ├── validators.dart       # Regex email, longitud password, rangos numéricos
│   │       └── extensions.dart       # Helpers para String, DateTime, List
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── product_model.dart
│   │   │   ├── category_model.dart
│   │   │   ├── supplier_model.dart
│   │   │   ├── cart_item_model.dart
│   │   │   ├── order_model.dart
│   │   │   └── order_detail_model.dart
│   │   ├── datasources/
│   │   │   ├── remote/
│   │   │   │   ├── auth_remote_ds.dart
│   │   │   │   ├── product_remote_ds.dart
│   │   │   │   ├── order_remote_ds.dart
│   │   │   │   └── user_remote_ds.dart
│   │   │   └── local/
│   │   │       ├── cart_local_ds.dart      # SharedPrefs (fallback offline)
│   │   │       ├── theme_local_ds.dart     # Preferencia modo oscuro
│   │   │       └── locale_local_ds.dart    # Idioma guardado
│   │   └── repositories/
│   │       ├── auth_repo_impl.dart
│   │       ├── product_repo_impl.dart
│   │       ├── cart_repo_impl.dart
│   │       ├── order_repo_impl.dart
│   │       └── user_repo_impl.dart
│   ├── presentation/
│   │   ├── providers/                # ChangeNotifiers (State Management Central)
│   │   │   ├── auth_provider.dart
│   │   │   ├── catalog_provider.dart
│   │   │   ├── cart_provider.dart
│   │   │   ├── order_provider.dart
│   │   │   ├── theme_provider.dart
│   │   │   └── locale_provider.dart
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── register_screen.dart
│   │   │   ├── home/
│   │   │   │   ├── catalog_screen.dart
│   │   │   │   └── product_detail_screen.dart
│   │   │   ├── search/
│   │   │   │   └── search_screen.dart
│   │   │   ├── cart/
│   │   │   │   └── cart_screen.dart
│   │   │   ├── favorites/
│   │   │   │   └── favorites_screen.dart
│   │   │   ├── profile/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── settings_screen.dart
│   │   │   │   └── order_history_screen.dart
│   │   │   └── splash_screen.dart
│   │   └── widgets/
│   │       ├── buttons/
│   │       │   ├── primary_button.dart
│   │       │   └── outline_button.dart
│   │       ├── inputs/
│   │       │   └── app_text_field.dart
│   │       ├── cards/
│   │       │   └── product_card.dart
│   │       ├── dialogs/
│   │       │   └── confirm_dialog.dart
│   │       ├── loaders/
│   │       │   ├── shimmer_grid.dart
│   │       │   └── circular_progress.dart
│   │       └── empty_state.dart
│   └── l10n/                         # Internacionalización
│       ├── app_en.arb
│       └── app_es.arb
├── assets/
│   ├── images/                       # Logo G, ilustraciones, banners, estados vacíos
│   ├── svgs/                         # Iconos SVG, badges, decoraciones
│   └── fonts/                        # Poppins-Regular, Medium, SemiBold, Bold
├── test/
│   ├── unit/                         # Modelos, validadores, lógica de providers
│   ├── widget/                       # Componentes UI, formularios, guards
│   └── integration/                  # Flujos completos con Firebase Emulator
├── firebase.json                     # Configuración emulators, hosting, rules
├── firestore.rules                   # Reglas de seguridad Firestore
├── .env                              # Variables de entorno (NO commitear)
├── .env.example                      # Plantilla pública
├── analysis_options.yaml             # Linter oficial + dart recommended
├── pubspec.yaml                      # Dependencias y configuración de assets
└── README.md                         # Guía de setup, arquitectura, scripts
```

---

## 3. 📦 DEPENDENCIAS (`pubspec.yaml`)

Organizadas por categoría para facilitar mantenimiento y auditoría. Versiones con `^` para parches seguros.

```yaml
name: game_shop
description: Tienda digital de videojuegos multiplataforma (iOS/Android).
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.24.0 <4.0.0'
  flutter: '>=3.24.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # 🔥 Firebase Core & Services
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
  cloud_firestore: ^5.4.4
  firebase_storage: ^12.3.2

  # 🧠 State Management (Provider)
  provider: ^6.1.2

  # 🧭 Routing & Guards
  go_router: ^14.2.3

  # 📱 UI/UX Components
  cached_network_image: ^3.3.1
  flutter_svg: ^2.0.10
  shimmer: ^3.0.0
  carousel_slider: ^5.0.0
  flutter_typeahead: ^5.2.0
  another_flushbar: ^1.12.30
  google_fonts: ^6.2.1
  intl: ^0.19.0
  fluttertoast: ^8.2.8

  # 💾 Local Storage & Connectivity
  shared_preferences: ^2.3.2
  connectivity_plus: ^6.0.5

  # 🛠 Utilities
  uuid: ^4.4.2
  equatable: ^2.0.5
  flutter_dotenv: ^5.1.0
  collection: ^1.18.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  generate: true
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf (weight: 500)
        - asset: assets/fonts/Poppins-SemiBold.ttf (weight: 600)
        - asset: assets/fonts/Poppins-Bold.ttf (weight: 700)
  assets:
    - assets/images/
    - assets/svgs/
    - .env
```

---

## 4. 📦 MODELOS DE DATOS

- **User**: `id_user`, `nombre`, `email`, `telefono`, `fecha_registro`, `tipo_usuario` (enum: `cliente`, `empleado`).
- **Product**: `id_product`, `titulo`, `descripcion`, `precio`, `stock`, `plataforma`, `id_categoria`, `id_proveedor`, `imagen_url`, `rating`, `disponible` (bool).
- **Category**: `id_category`, `nombre`, `descripcion`.
- **Order**: `id_order`, `id_user`, `fecha`, `total`, `estado` (enum: `pendiente`, `procesando`, `completado`, `cancelado`), `metodo_pago`.
- **OrderDetail**: `id_order`, `id_product`, `cantidad`, `precio_unitario` (subcolección).
- **Cart**: `id_user`, `id_product`, `cantidad`, `fecha_agregado` (colección o subcolección).
- **Favorites**: `id_user`, `id_product`, `fecha_agregado` (subcolección de `users`).
- **Supplier**: `id_supplier`, `nombre`, `contacto`, `pais`.

Cada modelo incluirá:
- `fromJson` / `toJson` para serialización segura.
- Validaciones en constructor/factory.
- Inmutabilidad donde aplique (`final` fields).
- Uso de `enum` para estados y tipos de usuario.

---

## 5. 🔌 SERVICIOS Y REPOSITORIOS

| Servicio | Responsabilidad |
|----------|----------------|
| **AuthService** | `signIn`, `signUp`, `signOut`, `resetPassword`, persistencia de sesión, escucha de `authStateChanges`. |
| **ProductService** | CRUD productos, búsqueda con debounce, filtros por categoría/plataforma/precio, paginación. |
| **CartService** | Agregar/eliminar/actualizar cantidad, calcular totales, mover a favoritos, sincronización local/remota. |
| **OrderService** | Crear pedido (transacción Firestore), historial por usuario, detalles por ID, watch de estado. |
| **UserService** | Perfil, favoritos, preferencias, toggles de notificaciones/idioma/tema. |

Patrón: Interfaces abstractas en `data/repositories/`, implementaciones en `data/datasources/`. Esto permite mockeo limpio y desacoplamiento de Firebase.

---

## 6. 📊 GESTIÓN DE ESTADO (PROVIDER - ÉNFASIS TÉCNICO)

### 6.1. Configuración Global
- `MultiProvider` en `main.dart` con `ChangeNotifierProvider.create`.
- Providers globales: `AuthProvider`, `CartProvider`, `ThemeProvider`, `LocaleProvider`.
- Providers locales: `CatalogProvider`, `SearchProvider`, `OrderDetailProvider`.

### 6.2. Buenas Prácticas Obligatorias
- ✅ `context.select<Provider, T>((p) => p.valor)` para reconstrucciones quirúrgicas.
- ✅ `Provider.of<Provider>(context, listen: false)` en callbacks (`onPressed`, `onSubmit`).
- ✅ Estados computados (`get total => ...`, `get isValid => ...`) dentro del `ChangeNotifier`.
- ❌ Nunca `context.watch` en builders de listas o grids.
- 🔄 `notifyListeners()` solo al final de operaciones atómicas o en `finally`.
- 💾 Sincronización con `shared_preferences` en `init`/`dispose` para preferencias y carrito offline.

### 6.3. Patrón de `ChangeNotifier`
```dart
// Estructura conceptual (NO CÓDIGO DE IMPLEMENTACIÓN)
class XProvider extends ChangeNotifier {
  final XRepository _repo;
  List<T> _data = [];
  bool _isLoading = false;
  String? _error;

  List<T> get data => List.unmodifiable(_data);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadData() async {
    _isLoading = true; notifyListeners();
    try { /* fetch */ } catch (e) { _error = e.toString(); } finally { _isLoading = false; notifyListeners(); }
  }
}
```

---

## 7. 📱 PANTALLAS Y FLUJO DE NAVEGACIÓN

### 7.1. Diagrama de Flujo
```
Splash/Init → AuthGuard
   ├── Autenticado → BottomNavigation (5 tabs)
   │   ├── 🏠 Catálogo
   │   ├── 🔍 Búsqueda
   │   ├── 🛒 Carrito (badge)
   │   ├── ❤️ Favoritos
   │   └── 👤 Perfil
   └── No Autenticado → /login → /register / /forgot-password
```
- **AuthGuard**: Intercepta rutas protegidas. Si `!AuthState.isAuthenticated`, redirige a `/login`. Si `tipo_usuario == 'admin'`, bloquea acceso a UI cliente y muestra `Acceso Restringido`.
- **Rutas Nombradas**: `go_router` con `redirect` callback para guards declarativos y `refreshListenable` atado a `AuthProvider`.

---

## 8. 🎨 UI COMPONENTS REUTILIZABLES

Widgets a estandarizar en `lib/presentation/widgets/`:
1. `PrimaryButton` / `OutlineButton` (estados: idle, loading, disabled; radio 12-16px)
2. `AppTextField` (validador integrado, iconos prefix/suffix, mensajes de error)
3. `ProductCard` (imagen, título, precio, rating, botón corazón, sombra sutil)
4. `RatingBar` (estrellas .5, estático/interactivo)
5. `EmptyStateWidget` (ilustración, texto, CTA opcional)
6. `ShimmerLoader` / `CircularProgress` (skeletons para grid/list)
7. `CustomBadge` (contador carrito)
8. `FilterChips` / `DropdownSelector` (categoría, plataforma, precio)
9. `FlushbarNotification` (éxito, error, advertencia)
10. `ToggleSetting` (notificaciones, dark mode, idioma)

---

## 9. 🔐 REGLAS DE SEGURIDAD FIRESTORE

```
match /databases/{database}/documents {
  match /categories/{id} { allow read: if true; }
  match /suppliers/{id} { allow read: if true; }
  match /products/{id} { allow read: if resource.data.disponible == true; }

  match /users/{userId} {
    allow read: if request.auth != null && request.auth.uid == userId;
    allow create: if request.auth != null && request.resource.data.id_user == request.auth.uid;
    allow update: if request.auth != null && request.auth.uid == userId;
  }

  match /users/{userId}/cart/{docId},
        /users/{userId}/favorites/{docId} {
    allow read, write, delete: if request.auth != null && request.auth.uid == userId;
  }

  match /orders/{orderId} {
    allow read: if resource.data.id_user == request.auth.uid || request.auth.token.tipo_usuario == 'empleado';
    allow create: if request.auth != null && request.resource.data.id_user == request.auth.uid;
    allow update: if resource.data.id_user == request.auth.uid && request.resource.data.estado == 'pendiente';
  }
}
```
- Validación de `request.auth.token.tipo_usuario` vía Custom Claims.
- Reglas actualizadas vía `firebase deploy --only firestore:rules`.

---

## 10. 📅 PLAN DE DESARROLLO POR FASES

| Fase | Duración | Entregables Clave |
|------|----------|-------------------|
| **Fase 1** | 1-2 sem | Configuración Firebase, Auth (login/registro/recuperación), persistencia sesión, `MultiProvider` base, routing guards, tema global |
| **Fase 2** | 1 sem | Modelos productos, `ProductService`, grid catálogo, filtros, detalle producto, búsqueda con debounce, caché básico |
| **Fase 3** | 1-2 sem | `CartService`, provider carrito, UI carrito, cálculo automático, creación pedido (simulado), historial órdenes |
| **Fase 4** | 1 sem | Favoritos (subcolección), perfil editable, toggles configuración, i18n ES/EN, cierre de sesión seguro |
| **Fase 5** | 1 sem | Tests unit/widget/integration, emuladores, optimización UI/UX, preparación builds, documentación final |

---

## 11. 🧪 ESTRATEGIA DE TESTING

- **Unitarios**: Modelos (`fromJson/toJson`), validadores, lógica de carrito/pedidos, providers (repos mockeados con `mocktail`).
- **Widget**: `ProductCard`, `AppTextField`, formularios auth, estados vacíos, navegación mockeada.
- **Integration**: Flujo completo `Registro → Login → Búsqueda → Carrito → Checkout → Historial`. Ejecutado en `Firebase Emulator Suite` local.
- **Performance**: `flutter run --profile`, DevTools Memory/Network, detección de rebuilds innecesarios y fugas de escucha.

---

## 12. 🚀 PREPARACIÓN PARA DEPLOY

### 12.1. Android
- `minSdkVersion 23`, `targetSdkVersion 34`.
- `keystore.jks` + `key.properties` en `android/app/build.gradle`.
- `flutter build appbundle` → Upload a Play Console (Internal → Production).

### 12.2. iOS
- `Info.plist`: permisos, `CFBundleLocalizations`, `ITSAppUsesNonExemptEncryption`.
- Certificados + Provisioning Profiles.
- `flutter build ipa` → Xcode Organizer / `altool` → App Store Connect.

### 12.3. Entorno
- `flutter_dotenv` con `.env` (dev/prod).
- Scripts: `flutter build appbundle --dart-define-from-file=env/prod.json`.

---

## 13. ⚡ CONSIDERACIONES DE PERFORMANCE

| Área | Estrategia |
|------|------------|
| **Paginación** | `limit(20)` + `startAfterDocument()`. Scroll infinito con `ScrollController`. |
| **Carga Lazy** | `GridView.builder` / `ListView.builder`. `CachedNetworkImage` con placeholder/error. |
| **Caché Offline** | Firestore persistence activado. `shared_preferences` para preferencias/carrito. Restore al iniciar app. |
| **Queries** | Índices compuestos `(categoria, plataforma)`, `(disponible, precio)`. Evitar `get()` en rules cuando sea posible. |
| **Rebuilds** | `context.select()` en UI, `listen: false` en callbacks, evitar `setState()` global. |
| **Reducción de Reads** | Batch writes para carrito/favoritos. Cache en memoria para productos frecuentes. |

---

## ✅ CHECKLIST DE VALIDACIÓN ANTES DE INICIAR

- [ ] Proyecto Firebase creado sin Analytics
- [ ] Firestore en modo estándar + reglas `deny all`
- [ ] Auth habilitado (Email/Password) + emails configurados
- [ ] Estructura de carpetas creada exactamente como el diagrama
- [ ] `pubspec.yaml` configurado con todas las dependencias listadas
- [ ] `analysis_options.yaml` activado con lints recomendados
- [ ] Proveedores estructurados con `ChangeNotifier` + `context.select`
- [ ] GoRouter configurado con `AuthRedirect` y `refreshListenable`
- [ ] ARB files creados para ES/EN
- [ ] Emuladores Firebase listos para testing local
- [ ] Variables de entorno separadas por sabor (dev/prod)

---

## 🔄 PRÓXIMO PASO

Una vez apruebes este plan **integrado y completo**, procederé a entregar la implementación **módulo por módulo**, comenzando por:
1. `pubspec.yaml` + estructura de carpetas + `analysis_options.yaml`
2. `main.dart` + `MultiProvider` + `GoRouter` + inicialización Firebase
3. `AuthProvider` + Pantallas de Login/Registro (validaciones, UI, navegación)
4. Configuración de i18n, tema y assets

**¿Aprobas este plan o requieres ajustes en alguna sección antes de iniciar la codificación?**
# Prompt V2: 
Actúa como un desarrollador experto en Flutter/Dart y Firebase porque voy a crear una aplicación multiplataforma para iOS y Android llamada GameShop que es una tienda de videojuegos digital y necesito trabajar en Firebase Console configurando Cloud Firestore en edición estándar desactivando Google Analytics durante la creación del proyecto y habilitando la autenticación con email y password. Para la estructura de la base de datos en Firestore necesito que adaptes las colecciones basándote en un esquema relacional que incluye la colección users con campos como id_user, nombre, email único, telefono, fecha_registro y tipo_usuario que puede ser cliente o empleado, la colección products con id_product, titulo, descripcion, precio, stock, plataforma, id_categoria, id_proveedor, imagen_url, rating y disponible como booleano, la colección categories con id_category, nombre y descripcion, la colección orders con id_order, id_user, fecha, total, estado que puede ser pendiente procesando completado o cancelado, y metodo_pago, también necesito order_details con id_order, id_product, cantidad y precio_unitario, la colección cart que puede ser subcolección de users o colección separada con id_user, id_product, cantidad y fecha_agregado, la colección favorites como subcolección de users con id_user, id_product y fecha_agregado, y finalmente suppliers con id_supplier, nombre, contacto y pais.
Las funcionalidades que necesito son primero la autenticación con login con email y password, registro de nuevos usuarios, recuperación de contraseña, persistencia de sesión y es muy importante que NO se incluya acceso de administrador en la pantalla de login. Para las pantallas principales necesito una pantalla de Login y Registro con diseño limpio con logo G de GameShop, botón INICIAR SESIÓN primario en color azul, botón CREAR CUENTA secundario en outline, el tagline Tu tienda de videojuegos favorita, validación de campos y navegación entre login y registro. La pantalla de Catálogo o Home debe tener grid o list view de productos disponibles con tarjetas de producto que muestren imagen del juego, título, precio, rating con estrellas y botón rápido de favoritos, además necesito un buscador en la parte superior, filtros por categoría y plataforma, y que al hacer click en un producto se vaya a la pantalla de detalles. La pantalla de Detalle de Producto debe tener imagen principal grande, título y precio destacados, descripción completa, rating y reseñas, información de plataforma género y disponibilidad, botón Agregar al Carrito primario en azul, botón Agregar a Favoritos con ícono de corazón y productos relacionados.
La pantalla de Carrito de Compras debe mostrar lista de productos agregados donde cada item muestre imagen miniatura, título, precio unitario, selector de cantidad con más y menos, botón eliminar, el total a pagar calculado automáticamente, botón Seguir con Pago, botón Mis Compras para ver el historial y estado vacío si no hay productos. También necesito pantalla de Búsqueda con barra de búsqueda prominente, resultados en tiempo real, sugerencias mientras escribe y filtros avanzados de precio plataforma y categoría. La pantalla de Favoritos debe tener grid de productos favoritos con acceso rápido desde el navbar y posibilidad de mover al carrito directamente. La pantalla de Perfil y Configuración debe incluir información del usuario, toggle para notificaciones y promociones, toggle de modo oscuro, selector de idioma, versión de la app, sección Cuenta con Privacidad, Ayuda y Soporte, y el botón Cerrar Sesión en color rojo o rosa al final. También necesito una pantalla de Historial de Compras con lista de pedidos realizados y detalle de cada pedido con fecha total y estado, y posibilidad de ver detalle completo.
Para el diseño UI/UX necesito una paleta de colores con primario azul como #2563EB o similar, secundario azul oscuro o morado como #7C3AED, acento con gradiente azul-morado, fondo blanco o gris muy claro como #F8FAFC, texto principal en gris oscuro #1E293B, texto secundario en gris medio #64748B, éxito en verde, error o alerta en rojo, y logout en rosa o rojo suave. El estilo debe ser diseño minimalista y limpio, bordes redondeados en botones y tarjetas de 12 a 16px de radio, sombras sutiles con elevation, espaciado consistente con grid system de 8px, tipografía moderna como Poppins Inter o similar, iconos coherentes con Material Icons o FontAwesome, transiciones suaves entre pantallas y feedback visual en interacciones. La navegación debe ser con Bottom Navigation Bar con 4 o 5 items que son Inicio o Catálogo, Buscar, Carrito con badge de cantidad, Favoritos y Perfil.
Para las herramientas y dependencias necesito usar VS Code como principal o Android Studio, Flutter SDK en su última versión estable, Firebase CLI, y en el pubspec.yaml necesito las dependencias de firebase_core, firebase_auth, cloud_firestore, firebase_storage si hay imágenes, provider o riverpod para state management, get opcional para navegación, cached_network_image para imágenes, flutter_svg para iconos SVG, intl para formato de fechas y moneda, uuid para generar IDs, image_picker si se suben imágenes, shared_preferences para datos locales, fluttertoast o another_flushbar para notificaciones, shimmer para loading skeletons, carousel_slider para banners, y search_bar o flutter_typeahead para búsqueda. También necesito que la app sea responsive design para móvil y tablet, con soporte para modo oscuro, internacionalización en español e inglés, manejo de estados de carga, manejo de errores y validaciones, offline-first con cache de productos, optimización de imágenes y seguridad en reglas de Firestore.
Lo que necesito es que NO PROPORCIONES CÓDIGO TODAVÍA sino que generes un PLAN DE IMPLEMENTACIÓN DETALLADO en formato Markdown que incluya primero la configuración del proyecto con paso a paso para crear proyecto en Firebase Console, configuración de Firestore con reglas de seguridad iniciales, configuración de Authentication y conexión del proyecto Flutter con Firebase. También necesito la arquitectura del proyecto con estructura de carpetas recomendada, patrón de diseño como MVC MVVM o Clean Architecture, y organización de widgets modelos servicios y providers. Necesito los modelos de datos con clases Dart para cada colección, métodos de serialización y deserialización, y validaciones. Los servicios y repositorios deben incluir AuthService para login registro logout y recovery, ProductService para CRUD productos búsqueda y filtros, CartService para agregar eliminar y actualizar cantidad, OrderService para crear pedido e historial, y UserService para perfil y favoritos.
Para la gestión de estado necesito configuración de Provider o Riverpod, ChangeNotifiers necesarios y estados globales versus locales. Las pantallas y flujo de navegación deben incluir diagrama de navegación, rutas nombradas y guards de autenticación. Los UI components reutilizables deben ser una lista de widgets personalizados a crear como botones cards inputs loaders etc. Necesito las reglas de seguridad de Firestore con reglas por colección, validación de roles y protección de datos sensibles. El plan de desarrollo debe ser por fases donde la Fase 1 sea configuración y autenticación de 1 a 2 semanas, Fase 2 catálogo y búsqueda de 1 semana, Fase 3 carrito y checkout de 1 a 2 semanas, Fase 4 perfil y favoritos de 1 semana, y Fase 5 testing y optimización de 1 semana. Para testing necesito tests unitarios recomendados, tests de widget e integration tests. El deploy debe incluir preparación para Android en Play Store, preparación para iOS en App Store, configuración de build y variables de entorno. Finalmente necesito consideraciones de performance con lazy loading, paginación de productos, cache estratégico y optimización de queries en Firestore. El plan debe ser claro secuencial y listo para ejecutar donde cada paso sea específico y accionable priorizando las mejores prácticas de Flutter y Firebase y una vez que apruebe el plan procederé a solicitar el código módulo por módulo.

