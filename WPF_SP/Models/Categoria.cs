using CommunityToolkit.Mvvm.ComponentModel;

namespace WPF_SP.Models;

public partial class Categoria : ObservableObject
{
    [ObservableProperty] private int idCategoria;
    [ObservableProperty] private string nombreCategoria = string.Empty;
    [ObservableProperty] private string? descripcion;
    [ObservableProperty] private bool activo = true;
}
