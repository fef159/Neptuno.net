using System.Data;
using Microsoft.Data.SqlClient;
using WPF_SP.Models;

namespace WPF_SP.Data;

public sealed class NeptunoRepository : INeptunoRepository
{
    private readonly string _connectionString;

    public NeptunoRepository(string connectionString) => _connectionString = connectionString;

    public async Task<List<Producto>> ListarProductosAsync()
    {
        var items = new List<Producto>();
        await using var reader = await ExecuteReaderAsync("usp_Producto_ListarActivos");
        while (await reader.ReadAsync())
        {
            items.Add(new Producto
            {
                IdProducto = reader.GetInt32("IdProducto"),
                NombreProducto = reader.GetString("NombreProducto"),
                IdProveedor = reader.GetNullableInt32("IdProveedor"),
                IdCategoria = reader.GetNullableInt32("IdCategoria"),
                CantidadPorUnidad = reader.GetNullableString("CantidadPorUnidad"),
                PrecioUnidad = reader.GetNullableDecimal("PrecioUnidad") ?? 0,
                UnidadesEnExistencia = reader.GetNullableInt16("UnidadesEnExistencia") ?? 0,
                Activo = reader.GetBoolean("Activo")
            });
        }
        return items;
    }

    public Task<int> CrearProductoAsync(Producto p) => ExecuteInsertAsync("usp_Mvvm_Producto_Crear", "@IdProducto", command =>
    {
        command.Parameters.AddString("@NombreProducto", 40, p.NombreProducto);
        command.Parameters.AddNullableInt("@IdProveedor", p.IdProveedor);
        command.Parameters.AddNullableInt("@IdCategoria", p.IdCategoria);
        command.Parameters.AddString("@CantidadPorUnidad", 20, p.CantidadPorUnidad);
        command.Parameters.AddDecimal("@PrecioUnidad", p.PrecioUnidad);
        command.Parameters.Add("@UnidadesEnExistencia", SqlDbType.SmallInt).Value = p.UnidadesEnExistencia;
    });

    public Task ActualizarProductoAsync(Producto p) => ExecuteNonQueryAsync("usp_Mvvm_Producto_Actualizar", command =>
    {
        command.Parameters.AddWithValue("@IdProducto", p.IdProducto);
        command.Parameters.AddString("@NombreProducto", 40, p.NombreProducto);
        command.Parameters.AddNullableInt("@IdProveedor", p.IdProveedor);
        command.Parameters.AddNullableInt("@IdCategoria", p.IdCategoria);
        command.Parameters.AddString("@CantidadPorUnidad", 20, p.CantidadPorUnidad);
        command.Parameters.AddDecimal("@PrecioUnidad", p.PrecioUnidad);
        command.Parameters.Add("@UnidadesEnExistencia", SqlDbType.SmallInt).Value = p.UnidadesEnExistencia;
    });

    public Task EliminarProductoAsync(int id) => ExecuteNonQueryAsync("usp_Producto_EliminarLogico",
        command => command.Parameters.AddWithValue("@IdProducto", id));

    public async Task<List<Categoria>> ListarCategoriasAsync()
    {
        var items = new List<Categoria>();
        await using var reader = await ExecuteReaderAsync("usp_Categoria_ListarActivas");
        while (await reader.ReadAsync())
        {
            items.Add(new Categoria
            {
                IdCategoria = reader.GetInt32("IdCategoria"),
                NombreCategoria = reader.GetString("NombreCategoria"),
                Descripcion = reader.GetNullableString("Descripcion"),
                Activo = reader.GetBoolean("Activo")
            });
        }
        return items;
    }

    public Task<int> CrearCategoriaAsync(Categoria c) => ExecuteInsertAsync("usp_Mvvm_Categoria_Crear", "@IdCategoria", command =>
    {
        command.Parameters.AddString("@NombreCategoria", 15, c.NombreCategoria);
        command.Parameters.AddString("@Descripcion", -1, c.Descripcion);
    });

    public Task ActualizarCategoriaAsync(Categoria c) => ExecuteNonQueryAsync("usp_Mvvm_Categoria_Actualizar", command =>
    {
        command.Parameters.AddWithValue("@IdCategoria", c.IdCategoria);
        command.Parameters.AddString("@NombreCategoria", 15, c.NombreCategoria);
        command.Parameters.AddString("@Descripcion", -1, c.Descripcion);
    });

    public Task EliminarCategoriaAsync(int id) => ExecuteNonQueryAsync("usp_Categoria_EliminarLogico",
        command => command.Parameters.AddWithValue("@IdCategoria", id));

    public async Task<List<Proveedor>> BuscarProveedoresAsync(string? contacto, string? ciudad)
    {
        var items = new List<Proveedor>();
        await using var reader = await ExecuteReaderAsync("usp_Mvvm_Proveedor_Buscar", command =>
        {
            command.Parameters.AddString("@NombreContacto", 30, contacto);
            command.Parameters.AddString("@Ciudad", 15, ciudad);
        });
        while (await reader.ReadAsync())
        {
            items.Add(new Proveedor
            {
                IdProveedor = reader.GetInt32("IdProveedor"),
                NombreCompania = reader.GetString("NombreCompania"),
                NombreContacto = reader.GetNullableString("NombreContacto"),
                CargoContacto = reader.GetNullableString("CargoContacto"),
                Ciudad = reader.GetNullableString("Ciudad"),
                Pais = reader.GetNullableString("Pais"),
                Telefono = reader.GetNullableString("Telefono"),
                Activo = reader.GetBoolean("Activo")
            });
        }
        return items;
    }

    public Task<int> CrearProveedorAsync(Proveedor p) => ExecuteInsertAsync("usp_Mvvm_Proveedor_Crear", "@IdProveedor", command =>
    {
        AddProveedorParameters(command, p);
    });

    public Task ActualizarProveedorAsync(Proveedor p) => ExecuteNonQueryAsync("usp_Mvvm_Proveedor_Actualizar", command =>
    {
        command.Parameters.AddWithValue("@IdProveedor", p.IdProveedor);
        AddProveedorParameters(command, p);
    });

    public Task EliminarProveedorAsync(int id) => ExecuteNonQueryAsync("usp_Proveedor_EliminarLogico",
        command => command.Parameters.AddWithValue("@IdProveedor", id));

    public async Task<List<Pedido>> ListarPedidosAsync()
    {
        var items = new List<Pedido>();
        await using var reader = await ExecuteReaderAsync("usp_Pedido_ListarActivos");
        while (await reader.ReadAsync())
        {
            items.Add(new Pedido
            {
                IdPedido = reader.GetInt32("IdPedido"),
                IdCliente = reader.GetNullableInt32("IdCliente"),
                IdEmpleado = reader.GetNullableInt32("IdEmpleado"),
                FechaPedido = reader.GetNullableDateTime("FechaPedido"),
                FechaRequerida = reader.GetNullableDateTime("FechaRequerida"),
                FechaEnvio = reader.GetNullableDateTime("FechaEnvio"),
                TransportistaId = reader.GetNullableInt32("TransportistaId"),
                Destinatario = reader.GetNullableString("Destinatario"),
                CiudadDestino = reader.GetNullableString("CiudadDestino"),
                PaisDestino = reader.GetNullableString("PaisDestino"),
                Activo = reader.GetBoolean("Activo")
            });
        }
        return items;
    }

    public Task<int> CrearPedidoAsync(Pedido p) => ExecuteInsertAsync("usp_Mvvm_Pedido_Crear", "@IdPedido", command => AddPedidoParameters(command, p));

    public Task ActualizarPedidoAsync(Pedido p) => ExecuteNonQueryAsync("usp_Mvvm_Pedido_Actualizar", command =>
    {
        command.Parameters.AddWithValue("@IdPedido", p.IdPedido);
        AddPedidoParameters(command, p);
    });

    public Task EliminarPedidoAsync(int id) => ExecuteNonQueryAsync("usp_Pedido_EliminarLogico",
        command => command.Parameters.AddWithValue("@IdPedido", id));

    public async Task<List<DetallePedidoReporte>> ListarDetallesAsync(DateTime inicio, DateTime fin)
    {
        var items = new List<DetallePedidoReporte>();
        await using var reader = await ExecuteReaderAsync("usp_DetallePedido_ListarPorFechas", command =>
        {
            command.Parameters.Add("@FechaInicio", SqlDbType.Date).Value = inicio.Date;
            command.Parameters.Add("@FechaFin", SqlDbType.Date).Value = fin.Date;
        });
        while (await reader.ReadAsync())
        {
            items.Add(new DetallePedidoReporte
            {
                IdPedido = reader.GetInt32("IdPedido"),
                FechaPedido = reader.GetNullableDateTime("FechaPedido"),
                Cliente = reader.GetNullableString("Cliente"),
                Producto = reader.GetString("Producto"),
                PrecioUnidad = reader.GetDecimal("PrecioUnidad"),
                Cantidad = reader.GetInt16("Cantidad"),
                Descuento = reader.GetFloat("Descuento"),
                Importe = reader.GetDecimal("Importe")
            });
        }
        return items;
    }

    public async Task<List<ClienteResumen>> ListarClientesAsync()
    {
        var items = new List<ClienteResumen>();
        await using var reader = await ExecuteReaderAsync("usp_Mvvm_Cliente_Listar");
        while (await reader.ReadAsync())
        {
            items.Add(new ClienteResumen
            {
                ClienteID = reader.GetInt32("ClienteID"),
                Empresa = reader.GetString("Empresa")
            });
        }
        return items;
    }

    public Task<int> CrearReporteManualAsync(DateTime fechaReporte, int productoId, int? clienteId,
        string titulo, short cantidad, string? detalle) =>
        ExecuteInsertAsync("usp_Mvvm_ReporteManual_Crear", "@ReporteID", command =>
        {
            command.Parameters.Add("@FechaReporte", SqlDbType.Date).Value = fechaReporte.Date;
            command.Parameters.AddWithValue("@ProductoID", productoId);
            command.Parameters.AddNullableInt("@ClienteID", clienteId);
            command.Parameters.AddString("@Titulo", 100, titulo);
            command.Parameters.Add("@Cantidad", SqlDbType.SmallInt).Value = cantidad;
            command.Parameters.AddString("@Detalle", 500, detalle);
        });

    public async Task<List<ReporteManual>> ListarReportesManualesAsync(DateTime inicio, DateTime fin, int? productoId)
    {
        var items = new List<ReporteManual>();
        await using var reader = await ExecuteReaderAsync("usp_Mvvm_ReporteManual_Listar", command =>
        {
            command.Parameters.Add("@FechaInicio", SqlDbType.Date).Value = inicio.Date;
            command.Parameters.Add("@FechaFin", SqlDbType.Date).Value = fin.Date;
            command.Parameters.AddNullableInt("@ProductoID", productoId);
        });
        while (await reader.ReadAsync())
        {
            items.Add(new ReporteManual
            {
                ReporteID = reader.GetInt32("ReporteID"),
                FechaReporte = reader.GetDateTime(reader.GetOrdinal("FechaReporte")),
                ProductoID = reader.GetInt32("ProductoID"),
                Producto = reader.GetString("Producto"),
                ClienteID = reader.GetNullableInt32("ClienteID"),
                Cliente = reader.GetNullableString("Cliente"),
                Titulo = reader.GetString("Titulo"),
                Cantidad = reader.GetInt16("Cantidad"),
                Detalle = reader.GetNullableString("Detalle")
            });
        }
        return items;
    }

    public Task EliminarReporteManualAsync(int reporteId) => ExecuteNonQueryAsync(
        "usp_Mvvm_ReporteManual_EliminarLogico",
        command => command.Parameters.AddWithValue("@ReporteID", reporteId));

    private static void AddProveedorParameters(SqlCommand command, Proveedor p)
    {
        command.Parameters.AddString("@NombreCompania", 40, p.NombreCompania);
        command.Parameters.AddString("@NombreContacto", 30, p.NombreContacto);
        command.Parameters.AddString("@CargoContacto", 30, p.CargoContacto);
        command.Parameters.AddString("@Ciudad", 15, p.Ciudad);
        command.Parameters.AddString("@Pais", 15, p.Pais);
        command.Parameters.AddString("@Telefono", 24, p.Telefono);
    }

    private static void AddPedidoParameters(SqlCommand command, Pedido p)
    {
        command.Parameters.AddNullableInt("@IdCliente", p.IdCliente);
        command.Parameters.AddNullableInt("@IdEmpleado", p.IdEmpleado);
        command.Parameters.AddNullableDate("@FechaPedido", p.FechaPedido);
        command.Parameters.AddNullableDate("@FechaRequerida", p.FechaRequerida);
        command.Parameters.AddNullableDate("@FechaEnvio", p.FechaEnvio);
        command.Parameters.AddNullableInt("@TransportistaId", p.TransportistaId);
        command.Parameters.AddString("@Destinatario", 40, p.Destinatario);
        command.Parameters.AddString("@CiudadDestino", 30, p.CiudadDestino);
        command.Parameters.AddString("@PaisDestino", 30, p.PaisDestino);
    }

    private async Task<SqlDataReader> ExecuteReaderAsync(string procedure, Action<SqlCommand>? configure = null)
    {
        var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        var command = new SqlCommand(procedure, connection) { CommandType = CommandType.StoredProcedure };
        configure?.Invoke(command);
        return await command.ExecuteReaderAsync(CommandBehavior.CloseConnection);
    }

    private async Task ExecuteNonQueryAsync(string procedure, Action<SqlCommand> configure)
    {
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        await using var command = new SqlCommand(procedure, connection) { CommandType = CommandType.StoredProcedure };
        configure(command);
        await command.ExecuteNonQueryAsync();
    }

    private async Task<int> ExecuteInsertAsync(string procedure, string outputName, Action<SqlCommand> configure)
    {
        await using var connection = new SqlConnection(_connectionString);
        await connection.OpenAsync();
        await using var command = new SqlCommand(procedure, connection) { CommandType = CommandType.StoredProcedure };
        configure(command);
        var output = command.Parameters.Add(outputName, SqlDbType.Int);
        output.Direction = ParameterDirection.Output;
        await command.ExecuteNonQueryAsync();
        return (int)output.Value;
    }
}

internal static class SqlExtensions
{
    public static void AddString(this SqlParameterCollection parameters, string name, int size, string? value,
        SqlDbType type = SqlDbType.NVarChar)
    {
        var parameter = parameters.Add(name, type, size);
        parameter.Value = string.IsNullOrWhiteSpace(value) ? DBNull.Value : value.Trim();
    }

    public static void AddNullableInt(this SqlParameterCollection parameters, string name, int? value) =>
        parameters.Add(name, SqlDbType.Int).Value = value is null ? DBNull.Value : value.Value;

    public static void AddNullableDate(this SqlParameterCollection parameters, string name, DateTime? value) =>
        parameters.Add(name, SqlDbType.DateTime).Value = value is null ? DBNull.Value : value.Value;

    public static void AddDecimal(this SqlParameterCollection parameters, string name, decimal value)
    {
        var parameter = parameters.Add(name, SqlDbType.Money);
        parameter.Value = value;
    }

    public static int GetInt32(this SqlDataReader reader, string name) => reader.GetInt32(reader.GetOrdinal(name));
    public static short GetInt16(this SqlDataReader reader, string name) => reader.GetInt16(reader.GetOrdinal(name));
    public static decimal GetDecimal(this SqlDataReader reader, string name) => reader.GetDecimal(reader.GetOrdinal(name));
    public static float GetFloat(this SqlDataReader reader, string name) => reader.GetFloat(reader.GetOrdinal(name));
    public static bool GetBoolean(this SqlDataReader reader, string name) => reader.GetBoolean(reader.GetOrdinal(name));
    public static string GetString(this SqlDataReader reader, string name) => reader.GetString(reader.GetOrdinal(name));
    public static string? GetNullableString(this SqlDataReader reader, string name) => reader.IsDBNull(reader.GetOrdinal(name)) ? null : reader.GetString(reader.GetOrdinal(name));
    public static int? GetNullableInt32(this SqlDataReader reader, string name) => reader.IsDBNull(reader.GetOrdinal(name)) ? null : reader.GetInt32(reader.GetOrdinal(name));
    public static short? GetNullableInt16(this SqlDataReader reader, string name) => reader.IsDBNull(reader.GetOrdinal(name)) ? null : reader.GetInt16(reader.GetOrdinal(name));
    public static decimal? GetNullableDecimal(this SqlDataReader reader, string name) => reader.IsDBNull(reader.GetOrdinal(name)) ? null : reader.GetDecimal(reader.GetOrdinal(name));
    public static DateTime? GetNullableDateTime(this SqlDataReader reader, string name) => reader.IsDBNull(reader.GetOrdinal(name)) ? null : reader.GetDateTime(reader.GetOrdinal(name));
}
