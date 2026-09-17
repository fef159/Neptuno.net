using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using WPF_SP.Data;
using WPF_SP.Models;

namespace WPF_SP.ViewModels;

public partial class ReportesManualesViewModel(INeptunoRepository repository) : ObservableObject
{
    private CancellationTokenSource? filtroCancellation;

    public ObservableCollection<Producto> Productos { get; } = new();
    public ObservableCollection<Producto> ProductosFiltro { get; } = new();
    public ObservableCollection<ClienteResumen> Clientes { get; } = new();
    public ObservableCollection<ReporteManual> Reportes { get; } = new();

    [ObservableProperty] private DateTime fechaReporte = DateTime.Today;
    [ObservableProperty] private int? productoId;
    [ObservableProperty] private int? clienteId;
    [ObservableProperty] private string titulo = string.Empty;
    [ObservableProperty] private short cantidad = 1;
    [ObservableProperty] private string? detalle;

    [ObservableProperty] private DateTime filtroFechaInicio = DateTime.Today.AddMonths(-1);
    [ObservableProperty] private DateTime filtroFechaFin = DateTime.Today;
    [ObservableProperty] private int filtroProductoId;
    [ObservableProperty] private ReporteManual? selectedReporte;
    [ObservableProperty] private string? message = "Complete el formulario para registrar un reporte manual.";
    [ObservableProperty] private bool isBusy;
    [ObservableProperty] private bool hasError;

    partial void OnFiltroFechaInicioChanged(DateTime value) => ProgramarConsulta();
    partial void OnFiltroFechaFinChanged(DateTime value) => ProgramarConsulta();
    partial void OnFiltroProductoIdChanged(int value) => ProgramarConsulta();

    public async Task LoadAsync()
    {
        IsBusy = true;
        HasError = false;
        try
        {
            var productosTask = repository.ListarProductosAsync();
            var clientesTask = repository.ListarClientesAsync();
            await Task.WhenAll(productosTask, clientesTask);

            Productos.Clear();
            ProductosFiltro.Clear();
            ProductosFiltro.Add(new Producto { IdProducto = 0, NombreProducto = "Todos los productos" });
            foreach (var producto in await productosTask)
            {
                Productos.Add(producto);
                ProductosFiltro.Add(producto);
            }

            Clientes.Clear();
            Clientes.Add(new ClienteResumen { ClienteID = 0, Empresa = "Sin cliente" });
            foreach (var cliente in await clientesTask) Clientes.Add(cliente);

            await ConsultarAsync();
        }
        catch (Exception ex)
        {
            HasError = true;
            Message = $"No se pudo cargar el módulo de reportes manuales: {ex.Message}";
        }
        finally { IsBusy = false; }
    }

    [RelayCommand]
    private async Task GuardarAsync()
    {
        if (ProductoId is null or 0) { Message = "Seleccione un producto."; return; }
        if (string.IsNullOrWhiteSpace(Titulo)) { Message = "Escriba el título del reporte."; return; }
        if (Cantidad <= 0) { Message = "La cantidad debe ser mayor que cero."; return; }

        IsBusy = true;
        HasError = false;
        try
        {
            await repository.CrearReporteManualAsync(
                FechaReporte, ProductoId.Value, ClienteId is > 0 ? ClienteId : null,
                Titulo.Trim(), Cantidad, string.IsNullOrWhiteSpace(Detalle) ? null : Detalle.Trim());
            LimpiarFormulario();
            await ConsultarAsync();
            Message = "Reporte manual guardado mediante ExecuteNonQuery.";
        }
        catch (Exception ex)
        {
            HasError = true;
            Message = $"No se pudo guardar el reporte: {ex.Message}";
        }
        finally { IsBusy = false; }
    }

    [RelayCommand]
    private void Nuevo() => LimpiarFormulario();

    [RelayCommand]
    private async Task EliminarAsync()
    {
        if (SelectedReporte is null) { Message = "Seleccione un reporte de la lista."; return; }
        try
        {
            await repository.EliminarReporteManualAsync(SelectedReporte.ReporteID);
            await ConsultarAsync();
            Message = "Reporte desactivado mediante baja lógica.";
        }
        catch (Exception ex) { Message = $"No se pudo desactivar el reporte: {ex.Message}"; }
    }

    [RelayCommand]
    private void RestablecerFiltros()
    {
        FiltroFechaInicio = DateTime.Today.AddMonths(-1);
        FiltroFechaFin = DateTime.Today;
        FiltroProductoId = 0;
        ProgramarConsulta();
    }

    private void LimpiarFormulario()
    {
        FechaReporte = DateTime.Today;
        ProductoId = null;
        ClienteId = null;
        Titulo = string.Empty;
        Cantidad = 1;
        Detalle = null;
        Message = "Formulario listo para un nuevo reporte.";
    }

    private void ProgramarConsulta()
    {
        filtroCancellation?.Cancel();
        filtroCancellation?.Dispose();
        filtroCancellation = new CancellationTokenSource();
        _ = ConsultarConEsperaAsync(filtroCancellation.Token);
    }

    private async Task ConsultarConEsperaAsync(CancellationToken token)
    {
        try
        {
            await Task.Delay(400, token);
            await ConsultarAsync();
        }
        catch (OperationCanceledException) { }
    }

    private async Task ConsultarAsync()
    {
        if (FiltroFechaInicio.Date > FiltroFechaFin.Date)
        {
            Message = "La fecha inicial del filtro no puede ser posterior a la fecha final.";
            return;
        }

        var result = await repository.ListarReportesManualesAsync(
            FiltroFechaInicio, FiltroFechaFin, FiltroProductoId > 0 ? FiltroProductoId : null);
        Reportes.Clear();
        foreach (var reporte in result) Reportes.Add(reporte);
        SelectedReporte = Reportes.FirstOrDefault();
        Message = $"{Reportes.Count} reporte(s) manual(es) encontrado(s).";
    }
}
