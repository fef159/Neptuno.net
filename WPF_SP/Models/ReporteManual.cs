namespace WPF_SP.Models;

public sealed class ReporteManual
{
    public int ReporteID { get; init; }
    public DateTime FechaReporte { get; init; }
    public int ProductoID { get; init; }
    public string Producto { get; init; } = string.Empty;
    public int? ClienteID { get; init; }
    public string? Cliente { get; init; }
    public string Titulo { get; init; } = string.Empty;
    public short Cantidad { get; init; }
    public string? Detalle { get; init; }
}
