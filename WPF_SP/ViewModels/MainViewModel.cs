using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using WPF_SP.Data;

namespace WPF_SP.ViewModels;

public partial class MainViewModel : ObservableObject
{
    public ProductosViewModel Productos { get; }
    public CategoriasViewModel Categorias { get; }
    public ProveedoresViewModel Proveedores { get; }
    public PedidosViewModel Pedidos { get; }
    public ReportesViewModel Reportes { get; }
    public ReportesManualesViewModel ReportesManuales { get; }
    [ObservableProperty] private string startupMessage = "Conectando con SQL Server...";
    [ObservableProperty] private bool isDatabaseConnected;

    public MainViewModel(INeptunoRepository repository)
    {
        Productos = new(repository);
        Categorias = new(repository);
        Proveedores = new(repository);
        Pedidos = new(repository);
        Reportes = new(repository);
        ReportesManuales = new(repository);
    }

    [RelayCommand]
    private async Task CargarTodoAsync()
    {
        await Task.WhenAll(Productos.LoadAsync(), Categorias.LoadAsync(), Proveedores.LoadAsync(), Pedidos.LoadAsync(), ReportesManuales.LoadAsync());
        IsDatabaseConnected = !Productos.HasError && !Categorias.HasError && !Proveedores.HasError && !Pedidos.HasError && !ReportesManuales.HasError;
        StartupMessage = IsDatabaseConnected
            ? "Datos activos cargados desde NeptunoDB"
            : "No se pudo conectar con NeptunoDB";
    }
}
