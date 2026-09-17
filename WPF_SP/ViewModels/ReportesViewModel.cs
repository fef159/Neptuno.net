using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using WPF_SP.Data;
using WPF_SP.Models;

namespace WPF_SP.ViewModels;

public partial class ReportesViewModel(INeptunoRepository repository) : ObservableObject
{
    private readonly List<DetallePedidoReporte> resultadosBase = new();
    private CancellationTokenSource? filtroCancellation;

    public ObservableCollection<DetallePedidoReporte> Detalles { get; } = new();
    [ObservableProperty] private DateTime fechaInicio = DateTime.Today.AddMonths(-1);
    [ObservableProperty] private DateTime fechaFin = DateTime.Today;
    [ObservableProperty] private string? filtroCliente;
    [ObservableProperty] private string? filtroProducto;
    [ObservableProperty] private string? message = "Escriba o cambie los filtros para consultar el reporte.";
    [ObservableProperty] private bool isBusy;

    partial void OnFechaInicioChanged(DateTime value) => ProgramarConsulta();
    partial void OnFechaFinChanged(DateTime value) => ProgramarConsulta();
    partial void OnFiltroClienteChanged(string? value) => ProgramarConsulta();
    partial void OnFiltroProductoChanged(string? value) => ProgramarConsulta();

    private async void ProgramarConsulta()
    {
        filtroCancellation?.Cancel();
        filtroCancellation?.Dispose();
        filtroCancellation = new CancellationTokenSource();
        var token = filtroCancellation.Token;

        try
        {
            await Task.Delay(450, token);
            await ConsultarAsync();
        }
        catch (OperationCanceledException)
        {
            // Otro cambio de filtro reemplazó esta consulta pendiente.
        }
    }

    private async Task ConsultarAsync()
    {
        if (FechaInicio.Date > FechaFin.Date) { Message = "La fecha inicial no puede ser posterior a la fecha final."; return; }
        IsBusy = true;
        Message = "Consultando detalles de pedidos...";
        try
        {
            var result = await repository.ListarDetallesAsync(FechaInicio, FechaFin);
            resultadosBase.Clear();
            resultadosBase.AddRange(result);
            AplicarFiltrosLocales();
            Message = $"{Detalles.Count} detalle(s) encontrado(s).";
        }
        catch (Exception ex) { Message = $"No se pudo generar el reporte: {ex.Message}"; }
        finally { IsBusy = false; }
    }

    private void AplicarFiltrosLocales()
    {
        var cliente = FiltroCliente?.Trim();
        var producto = FiltroProducto?.Trim();

        var filtrados = resultadosBase.Where(item =>
            (string.IsNullOrEmpty(cliente) || (item.Cliente?.Contains(cliente, StringComparison.CurrentCultureIgnoreCase) ?? false)) &&
            (string.IsNullOrEmpty(producto) || item.Producto.Contains(producto, StringComparison.CurrentCultureIgnoreCase)));

        Detalles.Clear();
        foreach (var item in filtrados) Detalles.Add(item);
    }

    [RelayCommand]
    private void Limpiar()
    {
        filtroCancellation?.Cancel();
        Detalles.Clear();
        resultadosBase.Clear();
        FiltroCliente = null;
        FiltroProducto = null;
        FechaInicio = DateTime.Today.AddMonths(-1);
        FechaFin = DateTime.Today;
        Message = "Filtros restablecidos. Modifique un filtro para realizar la consulta.";
    }
}
