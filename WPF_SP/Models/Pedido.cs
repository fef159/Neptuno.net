using CommunityToolkit.Mvvm.ComponentModel;

namespace WPF_SP.Models;

public partial class Pedido : ObservableObject
{
    [ObservableProperty] private int idPedido;
    [ObservableProperty] private int? idCliente;
    [ObservableProperty] private int? idEmpleado;
    [ObservableProperty] private DateTime? fechaPedido = DateTime.Today;
    [ObservableProperty] private DateTime? fechaRequerida;
    [ObservableProperty] private DateTime? fechaEnvio;
    [ObservableProperty] private int? transportistaId;
    [ObservableProperty] private string? destinatario;
    [ObservableProperty] private string? ciudadDestino;
    [ObservableProperty] private string? paisDestino;
    [ObservableProperty] private bool activo = true;
}
