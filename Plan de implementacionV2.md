# 📋 PLAN DE IMPLEMENTACIÓN DETALLADO: GAME SHOP

Este documento establece la hoja de ruta técnica, arquitectónica y operativa para el desarrollo de **GameShop**. No incluye código fuente; está diseñado para ser validado paso a paso antes de iniciar la implementación modular.

---

## 1. 🔧 CONFIGURACIÓN DEL PROYECTO

### 1.1. Firebase Console
1. **Crear Proyecto**: Acceder a Firebase Console → `Agregar proyecto` → Nombre: `GameShop`.
2. **Google Analytics**: Desmarcar explícitamente `Habilitar Google Analytics para este proyecto` durante la creación.
3. **Firestore Database**:
   - Navegar a `Firestore Database` → `Crear base de datos`.
   - Seleccionar `Modo de producción` o `Estándar` según disponibilidad regional.
   - Elegir ubicación del servidor (`eur3` o `us-central` recomendadas para latencia global).
   - Dejar reglas iniciales en `Bloquear toda lectura/escritura` (se actualizarán en la Fase 1).
4. **Authentication**:
   - Ir a `Authentication` → `Get started` → Pestaña `Sign-in method`.
   - Habilitar `Correo electrónico/Contraseña`.
   - Deshabilitar `Crear cuentas desde la consola` si no es requerido.
   - Configurar `Plantillas de correo electrónico` para recuperación de contraseña (idioma ES/EN).

### 1.2. Conexión con Flutter
1. Instalar Firebase CLI: `npm install -g firebase-tools`.
2. Iniciar sesión: `firebase login`.
3. Ejecutar `flutterfire configure` en la raíz del proyecto Flutter para generar automáticamente los archivos de configuración nativos y el archivo `firebase_options.dart`.
4. Inicializar en `main()`: `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`

---

## 2. 🏗️ ARQUITECTURA DEL PROYECTO

### 2.1. Patrón de Diseño
Se utilizará una **Arquitectura Limpia simplificada con MVVM**, priorizando la separación de responsabilidades y la testabilidad:
- **Presentation**: Widgets, pantallas, gestión de estado (Provider), localización.
- **Domain**: Casos de uso, entidades puras (modelos sin lógica de Firebase).
- **Data**: Repositorios, fuentes de datos (Firestore, Cache local, Servicios).

### 2.2. Estructura de Carpetas
```
lib/
├── core/                 # Utilidades, constantes, temas, enrutadores, helpers
├── features/             # Módulos por dominio
│   ├── auth/             # Login, Registro, Recuperación
│   ├── catalog/          # Home, Búsqueda, Filtros, Detalle
│   ├── cart/             # Carrito, Checkout
│   ├── orders/           # Historial, Detalle pedido
│   └── profile/          # Configuración, Favoritos, Ajustes
├── shared/               # Widgets reutilizables, componentes UI, assets
├── providers/            # Global ChangeNotifiers (Auth, Cart, Theme, Locale)
├── data/
│   ├── models/           # Clases Dart para Firestore
│   ├── repositories/     # Abstracciones de acceso a datos
│   └── datasources/      # Firebase implementation, SharedPrefs
└── main.dart             # Entry point, MultiProvider setup, Router init
```

---

## 3. 📦 MODELOS DE DATOS

### 3.1. Entidades (Mapping Relacional → NoSQL)
- **User**: `id` (String), `nombre`, `email`, `telefono`, `fechaRegistro` (Timestamp), `tipoUsuario` (Enum: cliente, empleado).
- **Product**: `id`, `titulo`, `descripcion`, `precio` (double), `stock` (int), `plataforma`, `idCategoria`, `idProveedor`, `imagenUrl`, `rating` (double), `disponible` (bool).
- **Category**: `id`, `nombre`, `descripcion`.
- **Order**: `id`, `idUsuario`, `fecha`, `total`, `estado` (Enum), `metodoPago`.
- **OrderDetail**: `id`, `idProducto`, `cantidad`, `precioUnitario` (Subcolección bajo `orders/{id}/details`).
- **CartItem**: `id`, `idProducto`, `cantidad`, `fechaAgregado`.
- **FavoriteItem**: `idProducto`, `fechaAgregado` (Subcolección `users/{id}/favorites`).
- **Supplier**: `id`, `nombre`, `contacto`, `pais`.

### 3.2. Serialización y Validación
- Implementar `fromJson` y `toJson` en cada modelo.
- Validaciones de entrada: Regex para email, longitud mínima para nombre/contraseña, rangos numéricos para precio/stock, checks de enums.
- Uso de `factory` constructors para garantizar inmutabilidad donde sea posible.
- Los IDs se generarán con `uuid` antes de persistencia, o delegados a Firestore si se requiere orden estricto (se priorizará UUID para independencia del cliente).

---

## 4. 🔌 SERVICIOS Y REPOSITORIOS

### 4.1. Patrón Repositorio
- Definir interfaces abstractas (`IAuthRepository`, `IProductRepository`, etc.) en `data/repositories/`.
- Implementaciones en `data/datasources/` apuntando a `cloud_firestore` y `firebase_auth`.
- Esto permite mockear Firebase durante testing y facilita migración futura si fuera necesario.

### 4.2. Servicios por Dominio
| Servicio | Responsabilidad |
|--------------------------|
| **AuthService** | `signIn`, `signUp`, `signOut`, `resetPassword`, `persistSession`, `fetchUserType`, `streamAuthState` |
| **ProductService** | `fetchProductsPaginated`, `searchProducts`, `getProductById`, `getByCategory/Platform`, `watchAvailable` |
| **CartService** | `addToCart`, `updateQuantity`, `removeFromCart`, `clearCart`, `calculateTotal`, `moveToFavorites` |
| **OrderService** | `createOrder` (transacción), `getOrderHistory`, `getOrderDetails`, `watchOrderStatus` |
| **UserService** | `updateProfile`, `manageFavorites`, `fetchPreferences`, `manageNotifications` |

---

## 5. 📊 GESTIÓN DE ESTADO (ÉNFASIS EN PROVIDER)

### 5.1. Configuración Global
- `main.dart` envolverá la app en `MultiProvider` con `ChangeNotifierProvider.value` o `.create` según ciclo de vida.
- Providers globales: `AuthProvider`, `CartProvider`, `ThemeProvider`, `LocaleProvider`.
- Providers locales/específicos: `CatalogProvider` (por pantalla), `OrderDetailProvider` (por ruta).

### 5.2. Mejores Prácticas con Provider
- **Evitar rebuilds innecesarios**: Uso de `context.select((p) => p.valorEspecífico)` o `Consumer<Provider>(builder: (ctx, val, child) {})` para aislar reconstrucciones.
- **Estado computado**: Propiedades `get` dentro de los `ChangeNotifier` para totales, filtros aplicados, validaciones de formularios.
- **Separación UI/Logic**: Los `ChangeNotifier` nunca manipulan widgets. Emiten eventos o exponen streams/estado. La UI solo consume y despacha métodos (`notifyListeners()` solo al final de transacciones atómicas).
- **Persistencia**: `CartProvider` y `ThemeProvider` se sincronizarán con `shared_preferences` en `initState` y `dispose` para recuperación offline.

---

## 6. 📱 PANTALLAS Y FLUJO DE NAVEGACIÓN

### 6.1. Diagrama de Navegación
```
Splash/Init → AuthGuard
   ├── Autenticado → BottomNavigation (4/5 tabs)
   │   ├── 🏠 Inicio/Catálogo
   │   ├── 🔍 Búsqueda
   │   ├── 🛒 Carrito
   │   ├── ❤️ Favoritos
   │   └── 👤 Perfil
   └── No Autenticado → /login → /register / /forgot-password
```
- **Auth Guard Middleware**: Intercepta rutas protegidas. Si `!AuthState.isAuthenticated`, redirige a `/login`. Si `AuthState.user.tipoUsuario == admin` (caso raro por seguridad), bloquea acceso a UI cliente.
- **Rutas Nombradas**: Usar `MaterialApp.router` con `GoRouter` o `flutter_modular` (se recomienda `go_router` para guards declarativos), pero si se prefiere vanilla, `Navigator.pushNamed` con `onGenerateRoute`.

### 6.2. Estructura de Pantallas Principales
- **Login/Registro**: Formulario validado en tiempo real, toggle entre modos, logo G centrado, tagline, botones primario/outline.
- **Home**: `SliverAppBar` con buscador → `GridView.builder` con `ProductCard`. Filtros desplegables (categoría, plataforma).
- **Detalle Producto**: Hero animation en imagen → Info → Rating → Botones CTA → `CarouselSlider` para relacionados.
- **Carrito**: `ListView.separated` → `CartTile` → Footer fijo con total y CTA → Estado vacío con ilustración.
- **Búsqueda**: `TypeAheadField` para sugerencias → Resultados en tiempo real con debounce → Filtros avanzados (rango precio, multi-select plataforma).
- **Perfil/Favoritos/Historial**: Layout limpio con `ListTile` para ajustes, toggle switches estilizados, grid de favoritos, timeline de pedidos.

---

## 7. 🎨 COMPONENTES UI REUTILIZABLES

Lista de widgets a estandarizar en `lib/shared/widgets/`:
1. `PrimaryButton` / `OutlineButton` (con estados loading/disabled, radio 12-16px)
2. `AppTextField` (con validador, prefix/suffix, error message integrado)
3. `ProductCard` (imagen, título, precio, rating, botón fav flotante, sombra suave)
4. `RatingBar` (estrellas interactivas/estáticas, soporta .5)
5. `EmptyStateWidget` (ilustración, título, CTA opcional)
6. `LoadingSkeleton` / `ShimmerLoader` (para grid/list durante carga)
7. `CustomBadge` (para cantidad en carrito)
8. `FilterChips` / `DropdownSelector` (categoría, plataforma, rango de precio)
9. `ToastNotification` (flushbar/toast reutilizable para éxito/error)
10. `SectionTitle` (tipografía consistente, espaciado 8px grid)
11. `ToggleSetting` (notificaciones, modo oscuro, etc.)

---

## 8. 🔐 REGLAS DE SEGURIDAD FIRESTORE

### 8.1. Principios
- **Deny by default**. Acceso explícito por colección/documento.
- Validar `request.auth != null` para operaciones protegidas.
- Validar `request.resource.data` en escrituras.
- Uso de `allow` con condiciones compuestas para `tipo_usuario`.

### 8.2. Estructura de Reglas (Conceptual)
```
match /databases/{database}/documents {
  // Configuración pública
  match /categories/{id} { allow read: if true; }
  match /suppliers/{id} { allow read: if true; }
  match /products/{id} { allow read: if resource.data.disponible == true; }

  // Autenticación y Usuarios
  match /users/{userId} {
    allow read: if request.auth != null && request.auth.uid == userId;
    allow create: if request.auth != null && request.resource.data.id_user == request.auth.uid;
    allow update: if request.auth != null && request.auth.uid == userId;
  }

  // Carrito y Favoritos (subcolecciones o raíz)
  match /users/{userId}/cart/{docId} {
    allow read, write, delete: if request.auth != null && request.auth.uid == userId;
  }
  match /users/{userId}/favorites/{docId} {
    allow read, write, delete: if request.auth != null && request.auth.uid == userId;
  }

  // Pedidos (transaccional)
  match /orders/{orderId} {
    allow read: if resource.data.id_user == request.auth.uid || request.auth.token.tipo_usuario == 'empleado';
    allow create: if request.auth != null && request.resource.data.id_user == request.auth.uid;
    allow update: if resource.data.id_user == request.auth.uid && request.resource.data.estado == 'pendiente';
  }
}
```
- **Notas de Seguridad**: `tipo_usuario` se validará en Cloud Functions si se escalan pagos. En Firestore Rules, se usa `request.auth.token.tipo_usuario` (custom claims) para máxima seguridad, o se lee del documento `users` con `get()`.

---

## 9. 📅 PLAN DE DESARROLLO POR FASES

| Fase | Duración | Entregables |
|------|----------|-------------|
| **Fase 1: Configuración y Autenticación** | 1-2 sem | Proyecto Firebase, conexión Flutter, Auth (Login/Registro/Recuperación), persistencia de sesión, base routing, tema global, Provider inicial (AuthState) |
| **Fase 2: Catálogo y Búsqueda** | 1 sem | ProductModel, ProductService, GridView, filtros, detalle producto, caché offline básico, búsqueda en tiempo real con debounce |
| **Fase 3: Carrito y Checkout** | 1-2 sem | CartService, Provider global de carrito, UI carrito, cálculo automático, creación de pedidos (simulación de pago), historial de órdenes |
| **Fase 4: Perfil, Favoritos y Ajustes** | 1 sem | Subcolecciones favoritos, perfil editable, toggles (dark mode, notificaciones), i18n ES/EN, settings UI, cierre de sesión seguro |
| **Fase 5: Testing y Optimización** | 1 sem | Tests unitarios/widget, emuladores Firebase, refactors de performance, pulido UI/UX, preparación build, documentación técnica |

---

## 10. 🧪 ESTRATEGIA DE TESTING

- **Unitarios**: Modelos (`fromJson/toJson`), servicios (mockeando `FirebaseFirestore`), validaciones de formularios, lógica de cálculo de carrito/pedidos.
- **Widget Tests**: `ProductCard`, `PrimaryButton`, formularios de login/registro, estados vacíos, navegación entre pantallas mockeadas.
- **Integration Tests**: Flujo completo `Registro → Login → Buscar → Agregar al carrito → Checkout → Ver historial`. Uso de `Firebase Emulator Suite` para pruebas locales sin costo ni datos reales.
- **Mock Strategy**: Interfaces de repositorios inyectadas via `Provider` para testing. Uso de `mocktail` o `mockito`.

---

## 11. 🚀 PREPARACIÓN PARA DEPLOY

### 11.1. Android (Play Store)
- Configurar `android/app/build.gradle` (`minSdkVersion 23`, `compileSdkVersion 34+`).
- Generar `keystore.jks` y configurar `key.properties`.
- Generar App Bundle (`flutter build appbundle`).
- Configurar Play Console: app signing, store listing, screenshots, cumplimiento de políticas.

### 11.2. iOS (App Store)
- Configurar `ios/Runner/Info.plist` (permisos, localizaciones, `ITSAppUsesNonExemptEncryption`).
- Generar certificados y provisioning profiles en Apple Developer.
- Archivar desde Xcode o CLI (`flutter build ipa`).
- Configurar App Store Connect: metadata, testflight, review guidelines.

### 11.3. Entorno y Variables
- Uso de `flutter_dotenv` para separar `API_URL`, `FLAVOR`, `DEBUG_MODE`.
- Archivos `env/development.env`, `env/production.env`.
- Scripts de build condicional para empaquetar variables correctas por entorno.

---

## 12. ⚡ CONSIDERACIONES DE PERFORMANCE

| Área | Estrategia |
|------|------------|
| **Paginación** | Firestore `limit(20)` + `startAfterDocument()`. Infinite scroll con `ScrollController`. |
| **Carga Lazy** | `ListView.builder` / `GridView.builder`. Imágenes con `CachedNetworkImage` + `placeholder` y `errorWidget`. |
| **Caché Offline** | Firestore cache nativo activado por defecto. `shared_preferences` para preferencias UI. `Provider` restaura estado desde cache local al inicio. |
| **Optimización Queries** | Índices compuestos para `(categoria, plataforma)`, `(disponible, precio)`. Evitar `get()` en reglas si es posible. Usar `snapshots()` solo en colecciones activas. |
| **State Rebuilds** | `select()` en Provider, `Provider.of(context, listen: false)` en botones, evitar `setState()` innecesario. |
| **Reducción de Reads** | Batch operations para carrito/favoritos. Cache de productos frecuentes en memoria (Map + TTL opcional). |

---

## ✅ PRÓXIMOS PASOS

1. Revisar y aprobar esta arquitectura y plan de ejecución.
2. Confirmar preferencia de router (`go_router` vs vanilla) y patrón MVVM vs Clean Architecture completo.
3. Una vez aprobado, iniciaré la entrega de código **módulo por módulo** siguiendo estrictamente las fases definidas, comenzando por:
   - Configuración `pubspec.yaml` + estructura de carpetas
   - `Firebase` + `AuthProvider` + Pantallas de Login/Registro
   - Validación de UI y navegación base

¿Desea proceder con la aprobación de este plan o requiere ajustes en alguna sección (especialmente en el enfoque de Provider, estructura de subcolecciones o reglas de seguridad)?

# Prompt V2: 
Actúa como un desarrollador experto en Flutter/Dart y Firebase porque voy a crear una aplicación multiplataforma para iOS y Android llamada GameShop que es una tienda de videojuegos digital y necesito trabajar en Firebase Console configurando Cloud Firestore en edición estándar desactivando Google Analytics durante la creación del proyecto y habilitando la autenticación con email y password. Para la estructura de la base de datos en Firestore necesito que adaptes las colecciones basándote en un esquema relacional que incluye la colección users con campos como id_user, nombre, email único, telefono, fecha_registro y tipo_usuario que puede ser cliente o empleado, la colección products con id_product, titulo, descripcion, precio, stock, plataforma, id_categoria, id_proveedor, imagen_url, rating y disponible como booleano, la colección categories con id_category, nombre y descripcion, la colección orders con id_order, id_user, fecha, total, estado que puede ser pendiente procesando completado o cancelado, y metodo_pago, también necesito order_details con id_order, id_product, cantidad y precio_unitario, la colección cart que puede ser subcolección de users o colección separada con id_user, id_product, cantidad y fecha_agregado, la colección favorites como subcolección de users con id_user, id_product y fecha_agregado, y finalmente suppliers con id_supplier, nombre, contacto y pais.
Las funcionalidades que necesito son primero la autenticación con login con email y password, registro de nuevos usuarios, recuperación de contraseña, persistencia de sesión y es muy importante que NO se incluya acceso de administrador en la pantalla de login. Para las pantallas principales necesito una pantalla de Login y Registro con diseño limpio con logo G de GameShop, botón INICIAR SESIÓN primario en color azul, botón CREAR CUENTA secundario en outline, el tagline Tu tienda de videojuegos favorita, validación de campos y navegación entre login y registro. La pantalla de Catálogo o Home debe tener grid o list view de productos disponibles con tarjetas de producto que muestren imagen del juego, título, precio, rating con estrellas y botón rápido de favoritos, además necesito un buscador en la parte superior, filtros por categoría y plataforma, y que al hacer click en un producto se vaya a la pantalla de detalles. La pantalla de Detalle de Producto debe tener imagen principal grande, título y precio destacados, descripción completa, rating y reseñas, información de plataforma género y disponibilidad, botón Agregar al Carrito primario en azul, botón Agregar a Favoritos con ícono de corazón y productos relacionados.
La pantalla de Carrito de Compras debe mostrar lista de productos agregados donde cada item muestre imagen miniatura, título, precio unitario, selector de cantidad con más y menos, botón eliminar, el total a pagar calculado automáticamente, botón Seguir con Pago, botón Mis Compras para ver el historial y estado vacío si no hay productos. También necesito pantalla de Búsqueda con barra de búsqueda prominente, resultados en tiempo real, sugerencias mientras escribe y filtros avanzados de precio plataforma y categoría. La pantalla de Favoritos debe tener grid de productos favoritos con acceso rápido desde el navbar y posibilidad de mover al carrito directamente. La pantalla de Perfil y Configuración debe incluir información del usuario, toggle para notificaciones y promociones, toggle de modo oscuro, selector de idioma, versión de la app, sección Cuenta con Privacidad, Ayuda y Soporte, y el botón Cerrar Sesión en color rojo o rosa al final. También necesito una pantalla de Historial de Compras con lista de pedidos realizados y detalle de cada pedido con fecha total y estado, y posibilidad de ver detalle completo.
Para el diseño UI/UX necesito una paleta de colores con primario azul como #2563EB o similar, secundario azul oscuro o morado como #7C3AED, acento con gradiente azul-morado, fondo blanco o gris muy claro como #F8FAFC, texto principal en gris oscuro #1E293B, texto secundario en gris medio #64748B, éxito en verde, error o alerta en rojo, y logout en rosa o rojo suave. El estilo debe ser diseño minimalista y limpio, bordes redondeados en botones y tarjetas de 12 a 16px de radio, sombras sutiles con elevation, espaciado consistente con grid system de 8px, tipografía moderna como Poppins Inter o similar, iconos coherentes con Material Icons o FontAwesome, transiciones suaves entre pantallas y feedback visual en interacciones. La navegación debe ser con Bottom Navigation Bar con 4 o 5 items que son Inicio o Catálogo, Buscar, Carrito con badge de cantidad, Favoritos y Perfil.
Para las herramientas y dependencias necesito usar VS Code como principal o Android Studio, Flutter SDK en su última versión estable, Firebase CLI, y en el pubspec.yaml necesito las dependencias de firebase_core, firebase_auth, cloud_firestore, firebase_storage si hay imágenes, provider o riverpod para state management, get opcional para navegación, cached_network_image para imágenes, flutter_svg para iconos SVG, intl para formato de fechas y moneda, uuid para generar IDs, image_picker si se suben imágenes, shared_preferences para datos locales, fluttertoast o another_flushbar para notificaciones, shimmer para loading skeletons, carousel_slider para banners, y search_bar o flutter_typeahead para búsqueda. También necesito que la app sea responsive design para móvil y tablet, con soporte para modo oscuro, internacionalización en español e inglés, manejo de estados de carga, manejo de errores y validaciones, offline-first con cache de productos, optimización de imágenes y seguridad en reglas de Firestore.
Lo que necesito es que NO PROPORCIONES CÓDIGO TODAVÍA sino que generes un PLAN DE IMPLEMENTACIÓN DETALLADO en formato Markdown que incluya primero la configuración del proyecto con paso a paso para crear proyecto en Firebase Console, configuración de Firestore con reglas de seguridad iniciales, configuración de Authentication y conexión del proyecto Flutter con Firebase. También necesito la arquitectura del proyecto con estructura de carpetas recomendada, patrón de diseño como MVC MVVM o Clean Architecture, y organización de widgets modelos servicios y providers. Necesito los modelos de datos con clases Dart para cada colección, métodos de serialización y deserialización, y validaciones. Los servicios y repositorios deben incluir AuthService para login registro logout y recovery, ProductService para CRUD productos búsqueda y filtros, CartService para agregar eliminar y actualizar cantidad, OrderService para crear pedido e historial, y UserService para perfil y favoritos.
Para la gestión de estado necesito configuración de Provider o Riverpod, ChangeNotifiers necesarios y estados globales versus locales. Las pantallas y flujo de navegación deben incluir diagrama de navegación, rutas nombradas y guards de autenticación. Los UI components reutilizables deben ser una lista de widgets personalizados a crear como botones cards inputs loaders etc. Necesito las reglas de seguridad de Firestore con reglas por colección, validación de roles y protección de datos sensibles. El plan de desarrollo debe ser por fases donde la Fase 1 sea configuración y autenticación de 1 a 2 semanas, Fase 2 catálogo y búsqueda de 1 semana, Fase 3 carrito y checkout de 1 a 2 semanas, Fase 4 perfil y favoritos de 1 semana, y Fase 5 testing y optimización de 1 semana. Para testing necesito tests unitarios recomendados, tests de widget e integration tests. El deploy debe incluir preparación para Android en Play Store, preparación para iOS en App Store, configuración de build y variables de entorno. Finalmente necesito consideraciones de performance con lazy loading, paginación de productos, cache estratégico y optimización de queries en Firestore. El plan debe ser claro secuencial y listo para ejecutar donde cada paso sea específico y accionable priorizando las mejores prácticas de Flutter y Firebase y una vez que apruebe el plan procederé a solicitar el código módulo por módulo.

