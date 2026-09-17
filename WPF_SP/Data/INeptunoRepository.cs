using WPF_SP.Models;

namespace WPF_SP.Data;

public interface INeptunoRepository
{
    Task<List<Producto>> ListarProductosAsync();
    Task<int> CrearProductoAsync(Producto producto);
    Task ActualizarProductoAsync(Producto producto);
    Task EliminarProductoAsync(int idProducto);

    Task<List<Categoria>> ListarCategoriasAsync();
    Task<int> CrearCategoriaAsync(Categoria categoria);
    Task ActualizarCategoriaAsync(Categoria categoria);
    Task EliminarCategoriaAsync(int idCategoria);

    Task<List<Proveedor>> BuscarProveedoresAsync(string? nombreContacto, string? ciudad);
    Task<int> CrearProveedorAsync(Proveedor proveedor);
    Task ActualizarProveedorAsync(Proveedor proveedor);
    Task EliminarProveedorAsync(int idProveedor);

    Task<List<Pedido>> ListarPedidosAsync();
    Task<int> CrearPedidoAsync(Pedido pedido);
    Task ActualizarPedidoAsync(Pedido pedido);
    Task EliminarPedidoAsync(int idPedido);

    Task<List<DetallePedidoReporte>> ListarDetallesAsync(DateTime fechaInicio, DateTime fechaFin);

    Task<List<ClienteResumen>> ListarClientesAsync();
    Task<int> CrearReporteManualAsync(DateTime fechaReporte, int productoId, int? clienteId,
        string titulo, short cantidad, string? detalle);
    Task<List<ReporteManual>> ListarReportesManualesAsync(DateTime fechaInicio, DateTime fechaFin, int? productoId);
    Task EliminarReporteManualAsync(int reporteId);
}
