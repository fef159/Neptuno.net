# Neptuno Manager con WPF y MVVM

Aplicación de escritorio para mantener productos, categorías, proveedores y pedidos de `NeptunoDB`. Incluye búsqueda de proveedores por nombre de contacto y ciudad, además de un reporte de detalles de pedidos por intervalo de fechas.

## Preparación

1. Si todavía no tiene Neptuno, ejecute `WPF_SP/seed.sql`.
2. Si Neptuno ya estaba instalado con el esquema del laboratorio, ejecute una sola vez `WPF_SP/migration_mvvm.sql` para agregar la baja lógica y los procedimientos compatibles.
3. Abra `WPF_SP.slnx` y ejecute el proyecto `WPF_SP`.

La conexión usa `Server=.` para acceder a la instancia predeterminada de SQL Server en el equipo local.

El script es idempotente: crea `NeptunoDB` y las tablas mínimas si no existen, agrega el campo `Activo` a las cuatro tablas solicitadas cuando sea necesario y usa `CREATE OR ALTER` para los procedimientos almacenados.

## Arquitectura MVVM

- **Models:** representan `Producto`, `Categoria`, `Proveedor`, `Pedido` y el resultado del reporte.
- **Views:** `MainWindow.xaml` solo contiene controles y enlaces de datos.
- **ViewModels:** exponen colecciones, selección, filtros y comandos para cargar, crear, guardar y dar de baja.
- **Data:** `NeptunoRepository` encapsula ADO.NET y es consumido mediante `INeptunoRepository`.

La vista no ejecuta SQL ni contiene reglas de negocio. El code-behind únicamente crea las dependencias, asigna el `DataContext` y dispara la carga inicial.

## ExecuteNonQuery

Todas las operaciones de escritura llaman procedimientos almacenados mediante `SqlCommand` con `CommandType.StoredProcedure`:

- Las inserciones usan `ExecuteInsertAsync`, que agrega un parámetro `OUTPUT`, ejecuta `ExecuteNonQueryAsync` y recupera el identificador generado.
- Las actualizaciones usan `ExecuteNonQueryAsync` directamente.
- Las bajas usan `ExecuteNonQueryAsync` y procedimientos `usp_*_EliminarLogico`.

Las lecturas y reportes usan `ExecuteReaderAsync`; por tanto, `ExecuteNonQuery` se aplica exclusivamente a las operaciones que modifican datos.

## Eliminación lógica

`Productos`, `Categorias`, `Proveedores` y `Pedidos` tienen `Activo BIT NOT NULL DEFAULT 1`. Los procedimientos de baja solo ejecutan `UPDATE ... SET Activo = 0`; el proyecto no contiene borrados físicos. Los procedimientos de listado y búsqueda aplican `WHERE Activo = 1`, y el reporte excluye pedidos inactivos mediante `p.Activo = 1`.

## Flujo de uso

- En cada mantenimiento, **Nuevo** agrega una fila editable, **Guardar** inserta o actualiza y **Baja lógica** desactiva la fila seleccionada.
- En proveedores, los filtros pueden combinar nombre del contacto y ciudad.
- En el reporte, ambas fechas son inclusivas y se valida que el inicio no sea posterior al fin.

## Conclusión

La separación MVVM permite probar o reemplazar la capa de datos sin modificar la interfaz. Los procedimientos almacenados centralizan la integridad de las escrituras y la baja lógica conserva el historial necesario para los detalles de pedidos.

## Matriz de cumplimiento del laboratorio

| Requisito | Implementación |
|---|---|
| Campo de estado en Productos, Categorias, Proveedores y Pedidos | `Activo BIT NOT NULL DEFAULT 1`, agregado sin borrar datos por `migration_mvvm.sql`. |
| CRUD de productos | Pestaña Productos, comandos MVVM y procedimientos de creación, actualización, listado y baja lógica. |
| CRUD de categorías | Pestaña Categorías, comandos MVVM y procedimientos de creación, actualización, listado y baja lógica. |
| CRUD de proveedores | Pestaña Proveedores, comandos MVVM y procedimientos de creación, actualización, listado y baja lógica. |
| Buscar proveedores por contacto y ciudad | Filtros combinables; solo devuelve `Activo = 1`. |
| CRUD de pedidos | Pestaña Pedidos, comandos MVVM y procedimientos de creación, actualización, listado y baja lógica. |
| Detalles de pedidos por fechas | Reporte con `INNER JOIN`, rango inclusivo y filtro `Pedidos.Activo = 1`. |
| Reportes manuales | Formulario MVVM para registrar fecha, producto, cliente, título, cantidad y detalle; almacenamiento con `ExecuteNonQuery` y consulta por fechas/producto. |
| ExecuteNonQuery | Todas las altas, actualizaciones y bajas pasan por `ExecuteNonQueryAsync`; las altas recuperan el ID mediante parámetro `OUTPUT`. |
| Sin eliminación física | Tanto los procedimientos MVVM como los procedimientos `usp_*_Eliminar` originales ejecutan `UPDATE Activo = 0`; no ejecutan `DELETE`. |
| Patrón MVVM | Modelos, vistas, ViewModels y repositorio ADO.NET están separados; la vista trabaja mediante bindings y comandos. |
| Scripts adjuntos | `seed.sql` para una instalación nueva y `migration_mvvm.sql` para la base Neptuno ya instalada. |

Para la entrega académica solo falta colocar en el documento el enlace del repositorio y las capturas finales de cada pestaña ejecutándose con datos.
