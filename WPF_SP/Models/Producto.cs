using CommunityToolkit.Mvvm.ComponentModel;

namespace WPF_SP.Models;

public partial class Producto : ObservableObject
{
    [ObservableProperty] private int idProducto;
    [ObservableProperty] private string nombreProducto = string.Empty;
    [ObservableProperty] private int? idProveedor;
    [ObservableProperty] private int? idCategoria;
    [ObservableProperty] private string? cantidadPorUnidad;
    [ObservableProperty] private decimal precioUnidad;
    [ObservableProperty] private short unidadesEnExistencia;
    [ObservableProperty] private bool activo = true;
}
