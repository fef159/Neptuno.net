namespace WPF_SP.Models;

public sealed class DetallePedidoReporte
{
    public int IdPedido { get; init; }
    public DateTime? FechaPedido { get; init; }
    public string? Cliente { get; init; }
    public string Producto { get; init; } = string.Empty;
    public decimal PrecioUnidad { get; init; }
    public short Cantidad { get; init; }
    public float Descuento { get; init; }
    public decimal Importe { get; init; }
}
