/* ============================================================
   NeptunoDB - esquema, datos mínimos y procedimientos almacenados
   Todas las bajas son lógicas: Activo = 0. Nunca se usa DELETE.
   ============================================================ */

IF DB_ID(N'NeptunoDB') IS NULL
    EXEC(N'CREATE DATABASE NeptunoDB');
GO

USE NeptunoDB;
GO

IF OBJECT_ID(N'dbo.Categorias', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Categorias
    (
        IdCategoria INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Categorias PRIMARY KEY,
        NombreCategoria NVARCHAR(15) NOT NULL,
        Descripcion NVARCHAR(MAX) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo DEFAULT (1)
    );
END;
GO

IF OBJECT_ID(N'dbo.Proveedores', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Proveedores
    (
        IdProveedor INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Proveedores PRIMARY KEY,
        NombreCompania NVARCHAR(40) NOT NULL,
        NombreContacto NVARCHAR(30) NULL,
        CargoContacto NVARCHAR(30) NULL,
        Ciudad NVARCHAR(15) NULL,
        Pais NVARCHAR(15) NULL,
        Telefono NVARCHAR(24) NULL,
        Activo BIT NOT NULL CONSTRAINT DF_Proveedores_Activo DEFAULT (1)
    );
END;
GO

IF OBJECT_ID(N'dbo.Productos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Productos
    (
        IdProducto INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Productos PRIMARY KEY,
        NombreProducto NVARCHAR(40) NOT NULL,
        IdProveedor INT NULL,
        IdCategoria INT NULL,
        CantidadPorUnidad NVARCHAR(20) NULL,
        PrecioUnidad MONEY NULL CONSTRAINT DF_Productos_Precio DEFAULT (0),
        UnidadesEnExistencia SMALLINT NULL CONSTRAINT DF_Productos_Stock DEFAULT (0),
        Activo BIT NOT NULL CONSTRAINT DF_Productos_Activo DEFAULT (1),
        CONSTRAINT FK_Productos_Proveedores FOREIGN KEY (IdProveedor) REFERENCES dbo.Proveedores(IdProveedor),
        CONSTRAINT FK_Productos_Categorias FOREIGN KEY (IdCategoria) REFERENCES dbo.Categorias(IdCategoria)
    );
END;
GO

IF OBJECT_ID(N'dbo.Pedidos', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Pedidos
    (
        IdPedido INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Pedidos PRIMARY KEY,
        IdCliente NCHAR(5) NULL,
        IdEmpleado INT NULL,
        FechaPedido DATETIME NULL,
        FechaEntrega DATETIME NULL,
        Destinatario NVARCHAR(40) NULL,
        CiudadDestinatario NVARCHAR(15) NULL,
        Cargo MONEY NULL CONSTRAINT DF_Pedidos_Cargo DEFAULT (0),
        Activo BIT NOT NULL CONSTRAINT DF_Pedidos_Activo DEFAULT (1)
    );
END;
GO

IF OBJECT_ID(N'dbo.DetallesPedido', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.DetallesPedido
    (
        IdPedido INT NOT NULL,
        IdProducto INT NOT NULL,
        PrecioUnidad MONEY NOT NULL,
        Cantidad SMALLINT NOT NULL,
        Descuento REAL NOT NULL CONSTRAINT DF_DetallesPedido_Descuento DEFAULT (0),
        CONSTRAINT PK_DetallesPedido PRIMARY KEY (IdPedido, IdProducto),
        CONSTRAINT FK_DetallesPedido_Pedidos FOREIGN KEY (IdPedido) REFERENCES dbo.Pedidos(IdPedido),
        CONSTRAINT FK_DetallesPedido_Productos FOREIGN KEY (IdProducto) REFERENCES dbo.Productos(IdProducto)
    );
END;
GO

/* Migración requerida si las cuatro tablas ya existían. */
IF COL_LENGTH(N'dbo.Productos', N'Activo') IS NULL
    ALTER TABLE dbo.Productos ADD Activo BIT NOT NULL CONSTRAINT DF_Productos_Activo_Migracion DEFAULT (1) WITH VALUES;
IF COL_LENGTH(N'dbo.Categorias', N'Activo') IS NULL
    ALTER TABLE dbo.Categorias ADD Activo BIT NOT NULL CONSTRAINT DF_Categorias_Activo_Migracion DEFAULT (1) WITH VALUES;
IF COL_LENGTH(N'dbo.Proveedores', N'Activo') IS NULL
    ALTER TABLE dbo.Proveedores ADD Activo BIT NOT NULL CONSTRAINT DF_Proveedores_Activo_Migracion DEFAULT (1) WITH VALUES;
IF COL_LENGTH(N'dbo.Pedidos', N'Activo') IS NULL
    ALTER TABLE dbo.Pedidos ADD Activo BIT NOT NULL CONSTRAINT DF_Pedidos_Activo_Migracion DEFAULT (1) WITH VALUES;
GO

/* ========================== PRODUCTOS ========================== */
CREATE OR ALTER PROCEDURE dbo.usp_Producto_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdProducto, NombreProducto, IdProveedor, IdCategoria, CantidadPorUnidad,
           PrecioUnidad, UnidadesEnExistencia, Activo
    FROM dbo.Productos
    WHERE Activo = 1
    ORDER BY NombreProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Crear
    @NombreProducto NVARCHAR(40), @IdProveedor INT = NULL, @IdCategoria INT = NULL,
    @CantidadPorUnidad NVARCHAR(20) = NULL, @PrecioUnidad MONEY = 0,
    @UnidadesEnExistencia SMALLINT = 0, @IdProducto INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Productos (NombreProducto, IdProveedor, IdCategoria, CantidadPorUnidad, PrecioUnidad, UnidadesEnExistencia, Activo)
    VALUES (@NombreProducto, @IdProveedor, @IdCategoria, @CantidadPorUnidad, @PrecioUnidad, @UnidadesEnExistencia, 1);
    SET @IdProducto = CONVERT(INT, SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_Actualizar
    @IdProducto INT, @NombreProducto NVARCHAR(40), @IdProveedor INT = NULL,
    @IdCategoria INT = NULL, @CantidadPorUnidad NVARCHAR(20) = NULL,
    @PrecioUnidad MONEY = 0, @UnidadesEnExistencia SMALLINT = 0
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Productos
       SET NombreProducto=@NombreProducto, IdProveedor=@IdProveedor, IdCategoria=@IdCategoria,
           CantidadPorUnidad=@CantidadPorUnidad, PrecioUnidad=@PrecioUnidad,
           UnidadesEnExistencia=@UnidadesEnExistencia
     WHERE IdProducto=@IdProducto AND Activo=1;
    IF @@ROWCOUNT = 0 THROW 51001, 'Producto activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Producto_EliminarLogico @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Productos SET Activo=0 WHERE IdProducto=@IdProducto AND Activo=1;
    IF @@ROWCOUNT = 0 THROW 51002, 'Producto activo no encontrado.', 1;
END;
GO

/* ========================== CATEGORIAS ========================= */
CREATE OR ALTER PROCEDURE dbo.usp_Categoria_ListarActivas
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdCategoria, NombreCategoria, Descripcion, Activo
    FROM dbo.Categorias WHERE Activo=1 ORDER BY NombreCategoria;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Crear
    @NombreCategoria NVARCHAR(15), @Descripcion NVARCHAR(MAX)=NULL, @IdCategoria INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Categorias (NombreCategoria, Descripcion, Activo)
    VALUES (@NombreCategoria, @Descripcion, 1);
    SET @IdCategoria=CONVERT(INT, SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_Actualizar
    @IdCategoria INT, @NombreCategoria NVARCHAR(15), @Descripcion NVARCHAR(MAX)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Categorias SET NombreCategoria=@NombreCategoria, Descripcion=@Descripcion
    WHERE IdCategoria=@IdCategoria AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51003, 'Categoria activa no encontrada.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Categoria_EliminarLogico @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Categorias SET Activo=0 WHERE IdCategoria=@IdCategoria AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51004, 'Categoria activa no encontrada.', 1;
END;
GO

/* ========================= PROVEEDORES ========================= */
CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Buscar
    @NombreContacto NVARCHAR(30)=NULL, @Ciudad NVARCHAR(15)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdProveedor, NombreCompania, NombreContacto, CargoContacto, Ciudad, Pais, Telefono, Activo
    FROM dbo.Proveedores
    WHERE Activo=1
      AND (NULLIF(LTRIM(RTRIM(@NombreContacto)), '') IS NULL OR NombreContacto LIKE N'%' + LTRIM(RTRIM(@NombreContacto)) + N'%')
      AND (NULLIF(LTRIM(RTRIM(@Ciudad)), '') IS NULL OR Ciudad LIKE N'%' + LTRIM(RTRIM(@Ciudad)) + N'%')
    ORDER BY NombreCompania;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Crear
    @NombreCompania NVARCHAR(40), @NombreContacto NVARCHAR(30)=NULL,
    @CargoContacto NVARCHAR(30)=NULL, @Ciudad NVARCHAR(15)=NULL,
    @Pais NVARCHAR(15)=NULL, @Telefono NVARCHAR(24)=NULL, @IdProveedor INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Proveedores (NombreCompania, NombreContacto, CargoContacto, Ciudad, Pais, Telefono, Activo)
    VALUES (@NombreCompania, @NombreContacto, @CargoContacto, @Ciudad, @Pais, @Telefono, 1);
    SET @IdProveedor=CONVERT(INT, SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_Actualizar
    @IdProveedor INT, @NombreCompania NVARCHAR(40), @NombreContacto NVARCHAR(30)=NULL,
    @CargoContacto NVARCHAR(30)=NULL, @Ciudad NVARCHAR(15)=NULL,
    @Pais NVARCHAR(15)=NULL, @Telefono NVARCHAR(24)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Proveedores
       SET NombreCompania=@NombreCompania, NombreContacto=@NombreContacto,
           CargoContacto=@CargoContacto, Ciudad=@Ciudad, Pais=@Pais, Telefono=@Telefono
     WHERE IdProveedor=@IdProveedor AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51005, 'Proveedor activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Proveedor_EliminarLogico @IdProveedor INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Proveedores SET Activo=0 WHERE IdProveedor=@IdProveedor AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51006, 'Proveedor activo no encontrado.', 1;
END;
GO

/* =========================== PEDIDOS =========================== */
CREATE OR ALTER PROCEDURE dbo.usp_Pedido_ListarActivos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT IdPedido, IdCliente, IdEmpleado, FechaPedido, FechaEntrega,
           Destinatario, CiudadDestinatario, Cargo, Activo
    FROM dbo.Pedidos WHERE Activo=1 ORDER BY FechaPedido DESC, IdPedido DESC;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Crear
    @IdCliente NCHAR(5)=NULL, @IdEmpleado INT=NULL, @FechaPedido DATETIME=NULL,
    @FechaEntrega DATETIME=NULL, @Destinatario NVARCHAR(40)=NULL,
    @CiudadDestinatario NVARCHAR(15)=NULL, @Cargo MONEY=0, @IdPedido INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT dbo.Pedidos (IdCliente, IdEmpleado, FechaPedido, FechaEntrega, Destinatario, CiudadDestinatario, Cargo, Activo)
    VALUES (@IdCliente, @IdEmpleado, @FechaPedido, @FechaEntrega, @Destinatario, @CiudadDestinatario, @Cargo, 1);
    SET @IdPedido=CONVERT(INT, SCOPE_IDENTITY());
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_Actualizar
    @IdPedido INT, @IdCliente NCHAR(5)=NULL, @IdEmpleado INT=NULL,
    @FechaPedido DATETIME=NULL, @FechaEntrega DATETIME=NULL,
    @Destinatario NVARCHAR(40)=NULL, @CiudadDestinatario NVARCHAR(15)=NULL, @Cargo MONEY=0
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Pedidos
       SET IdCliente=@IdCliente, IdEmpleado=@IdEmpleado, FechaPedido=@FechaPedido,
           FechaEntrega=@FechaEntrega, Destinatario=@Destinatario,
           CiudadDestinatario=@CiudadDestinatario, Cargo=@Cargo
     WHERE IdPedido=@IdPedido AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51007, 'Pedido activo no encontrado.', 1;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_Pedido_EliminarLogico @IdPedido INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Pedidos SET Activo=0 WHERE IdPedido=@IdPedido AND Activo=1;
    IF @@ROWCOUNT=0 THROW 51008, 'Pedido activo no encontrado.', 1;
END;
GO

/* ============================ REPORTE ========================== */
CREATE OR ALTER PROCEDURE dbo.usp_DetallePedido_ListarPorFechas
    @FechaInicio DATE, @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;
    IF @FechaInicio > @FechaFin THROW 51009, 'Rango de fechas invalido.', 1;

    SELECT d.IdPedido, p.FechaPedido, RTRIM(p.IdCliente) AS Cliente,
           pr.NombreProducto AS Producto, d.PrecioUnidad, d.Cantidad, d.Descuento,
           CONVERT(MONEY, d.PrecioUnidad * d.Cantidad * (1 - d.Descuento)) AS Importe
    FROM dbo.DetallesPedido d
    INNER JOIN dbo.Pedidos p ON p.IdPedido=d.IdPedido
    INNER JOIN dbo.Productos pr ON pr.IdProducto=d.IdProducto
    WHERE p.Activo=1
      AND p.FechaPedido >= @FechaInicio
      AND p.FechaPedido < DATEADD(DAY, 1, @FechaFin)
    ORDER BY p.FechaPedido, d.IdPedido, pr.NombreProducto;
END;
GO

/* Datos de demostración: solo se insertan en una base vacía. */
IF NOT EXISTS (SELECT 1 FROM dbo.Categorias)
    INSERT dbo.Categorias (NombreCategoria, Descripcion) VALUES
    (N'Bebidas', N'Bebidas, cafés y tés'), (N'Condimentos', N'Salsas y sazonadores');

IF NOT EXISTS (SELECT 1 FROM dbo.Proveedores)
    INSERT dbo.Proveedores (NombreCompania, NombreContacto, CargoContacto, Ciudad, Pais, Telefono) VALUES
    (N'Proveedor Andino', N'Ana Torres', N'Ventas', N'Lima', N'Perú', N'555-0101'),
    (N'Distribuidora Norte', N'Luis Vega', N'Gerente', N'Trujillo', N'Perú', N'555-0102');

IF NOT EXISTS (SELECT 1 FROM dbo.Productos)
    INSERT dbo.Productos (NombreProducto, IdProveedor, IdCategoria, CantidadPorUnidad, PrecioUnidad, UnidadesEnExistencia) VALUES
    (N'Café especial', 1, 1, N'10 cajas x 20 sobres', 18.00, 40),
    (N'Salsa picante', 2, 2, N'12 botellas', 12.50, 25);

IF NOT EXISTS (SELECT 1 FROM dbo.Pedidos)
BEGIN
    INSERT dbo.Pedidos (IdCliente, IdEmpleado, FechaPedido, FechaEntrega, Destinatario, CiudadDestinatario, Cargo)
    VALUES (N'DEMO1', 1, GETDATE(), DATEADD(DAY, 5, GETDATE()), N'Cliente Demo', N'Lima', 15.00);
END;

IF NOT EXISTS (SELECT 1 FROM dbo.DetallesPedido)
    INSERT dbo.DetallesPedido (IdPedido, IdProducto, PrecioUnidad, Cantidad, Descuento)
    SELECT TOP (1) pe.IdPedido, pr.IdProducto, pr.PrecioUnidad, 2, 0
    FROM dbo.Pedidos pe CROSS JOIN dbo.Productos pr
    ORDER BY pe.IdPedido, pr.IdProducto;
GO
