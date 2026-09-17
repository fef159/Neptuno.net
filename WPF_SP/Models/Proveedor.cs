using CommunityToolkit.Mvvm.ComponentModel;

namespace WPF_SP.Models;

public partial class Proveedor : ObservableObject
{
    [ObservableProperty] private int idProveedor;
    [ObservableProperty] private string nombreCompania = string.Empty;
    [ObservableProperty] private string? nombreContacto;
    [ObservableProperty] private string? cargoContacto;
    [ObservableProperty] private string? ciudad;
    [ObservableProperty] private string? pais;
    [ObservableProperty] private string? telefono;
    [ObservableProperty] private bool activo = true;
}
