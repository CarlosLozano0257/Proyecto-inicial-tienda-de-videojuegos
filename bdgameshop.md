# Actúa como un administrador de base de datos: proyecto tienda de videojuegos(gameshop), que entidades se necesitan para su gestión

<img width="905" height="545" alt="image" src="https://github.com/user-attachments/assets/b0e4fc7c-2b1c-4ab6-b6d7-25187b87ef2e" />

Para una tienda de videojuegos bien gestionada necesitas las siguientes entidades principales:Aquí tienes el desglose por grupos funcionales:

**Catálogo y stock**
`PRODUCTO` es el núcleo del sistema: almacena título, plataforma, precio y stock. Se relaciona con `CATEGORIA` (acción, RPG, deportes…) y `PROVEEDOR`. El `INVENTARIO` lleva el control de entradas/salidas en tiempo real, separado del campo `stock` del producto para tener historial.

**Ventas**
`PEDIDO` agrupa la transacción de un cliente. `DETALLE_PEDIDO` descompone línea por línea qué productos se compraron y a qué precio (guardas el precio histórico porque puede cambiar). `PAGO` registra el método, monto y estado de cobro por separado, lo que permite gestionar pagos parciales, reembolsos o múltiples métodos.

**Clientes y personal**
`CLIENTE` guarda los datos de quien compra. `EMPLEADO` puede asociarse a pedidos para saber qué cajero/agente gestionó cada venta (útil en tienda física o atención al cliente).

**Entidades que podrías agregar según el alcance del proyecto:**

- `PLATAFORMA` como tabla independiente (PS5, Xbox, PC…) si quieres filtros y reportes por plataforma
- `RESEÑA` vinculada a CLIENTE + PRODUCTO para valoraciones
- `DESCUENTO / CUPÓN` para promociones
- `DEVOLUCIÓN` ligada a PEDIDO para gestionar cambios
- `SUCURSAL` si hay múltiples tiendas físicas

¿Quieres que profundice en alguna entidad, que generemos el SQL para crear las tablas, o que agreguemos alguna funcionalidad específica como un sistema de puntos/fidelidad?

# Las entidades con sus atributos y tipo en forma de tabla para cada una de las entidades

## Tablas 
<img width="806" height="555" alt="image" src="https://github.com/user-attachments/assets/0ecbf5a4-b3bf-4dbf-8121-b575b12d5863" />

<img width="815" height="681" alt="image" src="https://github.com/user-attachments/assets/eac5235d-d5b3-4559-9aec-f5ae03f0a7a1" />

<img width="736" height="729" alt="image" src="https://github.com/user-attachments/assets/68157a5e-9cfc-49a9-b9bb-2b1773ddda79" />

## De acuerdo a tu respuesta anterior puedes generar un script en sql para descargar con el nombre de bdgameshop.sql para las 10 entidades con sus relaciones
