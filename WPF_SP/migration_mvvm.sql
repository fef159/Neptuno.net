/* Migración no destructiva para el esquema Neptuno ya instalado. */
USE NeptunoDB;
GO

IF COL_LENGTH(N'dbo.Productos', N'Activo') IS NULL
    ALTER TABLE dbo.Productos ADD Activo BIT NOT NULL CONSTRAINT DF_Productos_Activo DEFAULT (1) WITH VALUES;
IF COL_LENGTH(N'dbo.Categorias', N'Activo') IS NULL
    ALTER TABLE dbo.Categorias ADD Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo DEFAULT (1) WITH VALUES;
IF COL_LENGTH(N'dbo.Proveedores', N'Activo') IS NULL
    ALTER TABLE dbo.Proveedores ADD Activo BIT NOT NULL CONSTRAINT DF_Proveedores_Activo DEFAULT (1) WITH VALUES;
IF COL_LENGTH(N'dbo.Pedidos', N'Activo') IS NULL
    ALTER TABLE dbo.Pedidos ADD Activo BIT NOT NULL CONSTRAINT DF_Pedidos_Activo DEFAULT (1) WITH VALUES;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProductoID AS IdProducto, NombreProducto, ProveedorID AS IdProveedor,
           CategoriaID AS IdCategoria, CantidadPorUnidad, PrecioUnidad,
           UnidadesEnExistencia, Activo
    FROM dbo.Productos WHERE Activo=1 ORDER BY NombreProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Producto_Crear
    @NombreProducto NVARCHAR(60), @IdProveedor INT=NULL, @IdCategoria INT=NULL,
    @CantidadPorUnidad NVARCHAR(30)=NULL, @PrecioUnidad DECIMAL(10,2)=0,
    @UnidadesEnExistencia SMALLINT=0, @IdProducto INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Productos
        (NombreProducto, ProveedorID, CategoriaID, CantidadPorUnidad, PrecioUnidad,
         UnidadesEnExistencia, UnidadesEnPedido, NivelDeReorden, Descontinuado, Activo)
    VALUES
        (@NombreProducto, @IdProveedor, @IdCategoria, @CantidadPorUnidad, @PrecioUnidad,
         @UnidadesEnExistencia, 0, 0, 0, 1);
    SET @IdProducto=CONVERT(INT,SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Producto_Actualizar
    @IdProducto INT, @NombreProducto NVARCHAR(60), @IdProveedor INT=NULL,
    @IdCategoria INT=NULL, @CantidadPorUnidad NVARCHAR(30)=NULL,
    @PrecioUnidad DECIMAL(10,2)=0, @UnidadesEnExistencia SMALLINT=0
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Productos SET NombreProducto=@NombreProducto, ProveedorID=@IdProveedor,
        CategoriaID=@IdCategoria, CantidadPorUnidad=@CantidadPorUnidad,
        PrecioUnidad=@PrecioUnidad, UnidadesEnExistencia=@UnidadesEnExistencia
    WHERE ProductoID=@IdProducto AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51001, 'Producto activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_EliminarLogico @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Productos SET Activo=0 WHERE ProductoID=@IdProducto AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51002, 'Producto activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_ListarActivas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT CategoriaID AS IdCategoria, NombreCategoria, Descripcion, Activo
    FROM dbo.Categorias WHERE Activo=1 ORDER BY NombreCategoria;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Categoria_Crear
    @NombreCategoria NVARCHAR(30), @Descripcion NVARCHAR(200)=NULL,
    @IdCategoria INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Categorias (NombreCategoria,Descripcion,Activo)
    VALUES (@NombreCategoria,@Descripcion,1);
    SET @IdCategoria=CONVERT(INT,SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Categoria_Actualizar
    @IdCategoria INT, @NombreCategoria NVARCHAR(30), @Descripcion NVARCHAR(200)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Categorias SET NombreCategoria=@NombreCategoria, Descripcion=@Descripcion
    WHERE CategoriaID=@IdCategoria AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51003, 'Categoria activa no encontrada.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_EliminarLogico @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Categorias SET Activo=0 WHERE CategoriaID=@IdCategoria AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51004, 'Categoria activa no encontrada.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Proveedor_Buscar
    @NombreContacto NVARCHAR(40)=NULL, @Ciudad NVARCHAR(30)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ProveedorID AS IdProveedor, CompaniaNombre AS NombreCompania,
           NombreContacto, CargoContacto, Ciudad, Pais, Telefono, Activo
    FROM dbo.Proveedores
    WHERE Activo=1
      AND (NULLIF(LTRIM(RTRIM(@NombreContacto)),N'') IS NULL OR NombreContacto LIKE N'%'+LTRIM(RTRIM(@NombreContacto))+N'%')
      AND (NULLIF(LTRIM(RTRIM(@Ciudad)),N'') IS NULL OR Ciudad LIKE N'%'+LTRIM(RTRIM(@Ciudad))+N'%')
    ORDER BY CompaniaNombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Proveedor_Crear
    @NombreCompania NVARCHAR(60), @NombreContacto NVARCHAR(40)=NULL,
    @CargoContacto NVARCHAR(40)=NULL, @Ciudad NVARCHAR(30)=NULL,
    @Pais NVARCHAR(30)=NULL, @Telefono NVARCHAR(24)=NULL,
    @IdProveedor INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Proveedores
        (CompaniaNombre,NombreContacto,CargoContacto,Ciudad,Pais,Telefono,Activo)
    VALUES
        (@NombreCompania,@NombreContacto,@CargoContacto,@Ciudad,@Pais,@Telefono,1);
    SET @IdProveedor=CONVERT(INT,SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Proveedor_Actualizar
    @IdProveedor INT, @NombreCompania NVARCHAR(60),
    @NombreContacto NVARCHAR(40)=NULL, @CargoContacto NVARCHAR(40)=NULL,
    @Ciudad NVARCHAR(30)=NULL, @Pais NVARCHAR(30)=NULL, @Telefono NVARCHAR(24)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Proveedores SET CompaniaNombre=@NombreCompania,
        NombreContacto=@NombreContacto, CargoContacto=@CargoContacto,
        Ciudad=@Ciudad, Pais=@Pais, Telefono=@Telefono
    WHERE ProveedorID=@IdProveedor AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51005, 'Proveedor activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_EliminarLogico @IdProveedor INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Proveedores SET Activo=0 WHERE ProveedorID=@IdProveedor AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51006, 'Proveedor activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT PedidoID AS IdPedido, ClienteID AS IdCliente, EmpleadoID AS IdEmpleado,
           FechaPedido, FechaRequerida, FechaEnvio,
           TransportistaID AS TransportistaId, Destinatario,
           CiudadDestino, PaisDestino, Activo
    FROM dbo.Pedidos WHERE Activo=1 ORDER BY FechaPedido DESC, PedidoID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Pedido_Crear
    @IdCliente INT=NULL, @IdEmpleado INT=NULL, @FechaPedido DATE=NULL,
    @FechaRequerida DATE=NULL, @FechaEnvio DATE=NULL, @TransportistaId INT=NULL,
    @Destinatario NVARCHAR(60)=NULL, @CiudadDestino NVARCHAR(30)=NULL,
    @PaisDestino NVARCHAR(30)=NULL, @IdPedido INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Pedidos
        (ClienteID,EmpleadoID,FechaPedido,FechaRequerida,FechaEnvio,
         TransportistaID,Destinatario,CiudadDestino,PaisDestino,Activo)
    VALUES
        (@IdCliente,@IdEmpleado,@FechaPedido,@FechaRequerida,@FechaEnvio,
         @TransportistaId,@Destinatario,@CiudadDestino,@PaisDestino,1);
    SET @IdPedido=CONVERT(INT,SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Pedido_Actualizar
    @IdPedido INT, @IdCliente INT=NULL, @IdEmpleado INT=NULL,
    @FechaPedido DATE=NULL, @FechaRequerida DATE=NULL, @FechaEnvio DATE=NULL,
    @TransportistaId INT=NULL, @Destinatario NVARCHAR(60)=NULL,
    @CiudadDestino NVARCHAR(30)=NULL, @PaisDestino NVARCHAR(30)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Pedidos SET ClienteID=@IdCliente, EmpleadoID=@IdEmpleado,
        FechaPedido=@FechaPedido, FechaRequerida=@FechaRequerida,
        FechaEnvio=@FechaEnvio, TransportistaID=@TransportistaId,
        Destinatario=@Destinatario, CiudadDestino=@CiudadDestino, PaisDestino=@PaisDestino
    WHERE PedidoID=@IdPedido AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51007, 'Pedido activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_EliminarLogico @IdPedido INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Pedidos SET Activo=0 WHERE PedidoID=@IdPedido AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51008, 'Pedido activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_ListarPorFechas
    @FechaInicio DATE, @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaInicio>@FechaFin THROW 51009, 'Rango de fechas invalido.', 1;

    SELECT p.PedidoID AS IdPedido, p.FechaPedido,
           ISNULL(c.Empresa,N'Sin cliente') AS Cliente,
           pr.NombreProducto AS Producto, d.PrecioUnidad, d.Cantidad,
           CONVERT(REAL,d.Descuento) AS Descuento,
           CAST(d.PrecioUnidad*d.Cantidad*(1-d.Descuento) AS DECIMAL(12,2)) AS Importe
    FROM dbo.DetallePedidos d
    INNER JOIN dbo.Pedidos p ON p.PedidoID=d.PedidoID
    INNER JOIN dbo.Productos pr ON pr.ProductoID=d.ProductoID
    LEFT JOIN dbo.Clientes c ON c.ClienteID=p.ClienteID
    WHERE p.Activo=1 AND p.FechaPedido BETWEEN @FechaInicio AND @FechaFin
    ORDER BY p.FechaPedido,p.PedidoID,pr.NombreProducto;
END;
GO

/* Compatibilidad: los procedimientos originales también respetan la baja lógica. */
CREATE OR ALTER PROCEDURE dbo.usp_Producto_Eliminar @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Productos SET Activo=0 WHERE ProductoID=@ProductoID AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51010, 'Producto activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Eliminar @CategoriaID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Categorias SET Activo=0 WHERE CategoriaID=@CategoriaID AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51011, 'Categoria activa no encontrada.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Eliminar @ProveedorID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Proveedores SET Activo=0 WHERE ProveedorID=@ProveedorID AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51012, 'Proveedor activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Eliminar @PedidoID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Pedidos SET Activo=0 WHERE PedidoID=@PedidoID AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51013, 'Pedido activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.*,pr.CompaniaNombre AS ProveedorNombre,c.NombreCategoria AS CategoriaNombre
    FROM dbo.Productos p
    LEFT JOIN dbo.Proveedores pr ON pr.ProveedorID=p.ProveedorID
    LEFT JOIN dbo.Categorias c ON c.CategoriaID=p.CategoriaID
    WHERE p.Activo=1
    ORDER BY p.NombreProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Categorias WHERE Activo=1 ORDER BY NombreCategoria;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.*,c.Empresa AS ClienteNombre,
           CONCAT(e.Nombre,N' ',e.Apellidos) AS EmpleadoNombre,
           t.CompaniaNombre AS TransportistaNombre
    FROM dbo.Pedidos p
    LEFT JOIN dbo.Clientes c ON c.ClienteID=p.ClienteID
    LEFT JOIN dbo.Empleados e ON e.EmpleadoID=p.EmpleadoID
    LEFT JOIN dbo.Transportistas t ON t.TransportistaID=p.TransportistaID
    WHERE p.Activo=1
    ORDER BY p.FechaPedido DESC,p.PedidoID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Buscar
    @NombreContacto NVARCHAR(40)=NULL, @Ciudad NVARCHAR(30)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT * FROM dbo.Proveedores
    WHERE Activo=1
      AND (NULLIF(LTRIM(RTRIM(@NombreContacto)),N'') IS NULL OR NombreContacto LIKE N'%'+LTRIM(RTRIM(@NombreContacto))+N'%')
      AND (NULLIF(LTRIM(RTRIM(@Ciudad)),N'') IS NULL OR Ciudad LIKE N'%'+LTRIM(RTRIM(@Ciudad))+N'%')
    ORDER BY CompaniaNombre;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Reporte_DetallePedidosPorFecha
    @FechaInicio DATE, @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.PedidoID,p.FechaPedido,ISNULL(c.Empresa,N'Sin cliente') AS Cliente,
           ISNULL(p.Destinatario,N'') AS Destinatario,pr.NombreProducto AS Producto,
           d.PrecioUnidad,d.Cantidad,d.Descuento,
           CAST(d.PrecioUnidad*d.Cantidad*(1-d.Descuento) AS DECIMAL(12,2)) AS Subtotal
    FROM dbo.DetallePedidos d
    INNER JOIN dbo.Pedidos p ON p.PedidoID=d.PedidoID
    INNER JOIN dbo.Productos pr ON pr.ProductoID=d.ProductoID
    LEFT JOIN dbo.Clientes c ON c.ClienteID=p.ClienteID
    WHERE p.Activo=1 AND p.FechaPedido BETWEEN @FechaInicio AND @FechaFin
    ORDER BY p.FechaPedido,p.PedidoID,pr.NombreProducto;
END;
GO

/* Reportes registrados manualmente desde la aplicación. */
IF OBJECT_ID(N'dbo.ReportesManuales',N'U') IS NULL
BEGIN
    CREATE TABLE dbo.ReportesManuales
    (
        ReporteID INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_ReportesManuales PRIMARY KEY,
        FechaReporte DATE NOT NULL CONSTRAINT DF_ReportesManuales_Fecha DEFAULT (CONVERT(DATE,GETDATE())),
        ProductoID INT NOT NULL,
        ClienteID INT NULL,
        Titulo NVARCHAR(100) NOT NULL,
        Cantidad SMALLINT NOT NULL CONSTRAINT DF_ReportesManuales_Cantidad DEFAULT (1),
        Detalle NVARCHAR(500) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_ReportesManuales_Activo DEFAULT (1),
        CONSTRAINT FK_ReportesManuales_Producto FOREIGN KEY (ProductoID) REFERENCES dbo.Productos(ProductoID),
        CONSTRAINT FK_ReportesManuales_Cliente FOREIGN KEY (ClienteID) REFERENCES dbo.Clientes(ClienteID),
        CONSTRAINT CK_ReportesManuales_Cantidad CHECK (Cantidad>0)
    );
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_Cliente_Listar
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ClienteID,Empresa FROM dbo.Clientes ORDER BY Empresa;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_ReporteManual_Crear
    @FechaReporte DATE, @ProductoID INT, @ClienteID INT=NULL,
    @Titulo NVARCHAR(100), @Cantidad SMALLINT, @Detalle NVARCHAR(500)=NULL,
    @ReporteID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.ReportesManuales
        (FechaReporte,ProductoID,ClienteID,Titulo,Cantidad,Detalle,Activo)
    VALUES
        (@FechaReporte,@ProductoID,@ClienteID,@Titulo,@Cantidad,@Detalle,1);
    SET @ReporteID=CONVERT(INT,SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_ReporteManual_Listar
    @FechaInicio DATE, @FechaFin DATE, @ProductoID INT=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT r.ReporteID,r.FechaReporte,r.ProductoID,p.NombreProducto AS Producto,
           r.ClienteID,c.Empresa AS Cliente,r.Titulo,r.Cantidad,r.Detalle
    FROM dbo.ReportesManuales r
    INNER JOIN dbo.Productos p ON p.ProductoID=r.ProductoID
    LEFT JOIN dbo.Clientes c ON c.ClienteID=r.ClienteID
    WHERE r.Activo=1
      AND r.FechaReporte BETWEEN @FechaInicio AND @FechaFin
      AND (@ProductoID IS NULL OR r.ProductoID=@ProductoID)
    ORDER BY r.FechaReporte DESC,r.ReporteID DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Mvvm_ReporteManual_EliminarLogico @ReporteID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.ReportesManuales SET Activo=0 WHERE ReporteID=@ReporteID AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51014, 'Reporte manual activo no encontrado.', 1;
END;
GO
