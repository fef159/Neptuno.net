using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;
using WPF_SP.Data;
using WPF_SP.Models;

namespace WPF_SP.ViewModels;

public sealed class ProductosViewModel(INeptunoRepository repository) : CrudViewModel<Producto>
{
    public System.Collections.ObjectModel.ObservableCollection<Categoria> CategoriasDisponibles { get; } = new();
    public System.Collections.ObjectModel.ObservableCollection<Proveedor> ProveedoresDisponibles { get; } = new();

    public override async Task LoadAsync() => await RunAsync(async () =>
    {
        var productosTask = repository.ListarProductosAsync();
        var categoriasTask = repository.ListarCategoriasAsync();
        var proveedoresTask = repository.BuscarProveedoresAsync(null, null);
        await Task.WhenAll(productosTask, categoriasTask, proveedoresTask);

        CategoriasDisponibles.Clear();
        foreach (var categoria in await categoriasTask) CategoriasDisponibles.Add(categoria);

        ProveedoresDisponibles.Clear();
        foreach (var proveedor in await proveedoresTask) ProveedoresDisponibles.Add(proveedor);

        Items.Clear();
        foreach (var producto in await productosTask) Items.Add(producto);
        SelectedItem = Items.FirstOrDefault();
        Message = $"{Items.Count} registro(s) activo(s).";
    }, "No se pudieron cargar los productos, categorías y proveedores");

    protected override Task<List<Producto>> LoadItemsAsync() => repository.ListarProductosAsync();
    protected override Task<int> InsertAsync(Producto item) => repository.CrearProductoAsync(item);
    protected override Task UpdateAsync(Producto item) => repository.ActualizarProductoAsync(item);
    protected override Task DeletePersistedAsync(int id) => repository.EliminarProductoAsync(id);
    protected override Producto CreateNew() => new();
    protected override int GetId(Producto item) => item.IdProducto;
    protected override void SetId(Producto item, int id) => item.IdProducto = id;
    protected override string? Validate(Producto item) => string.IsNullOrWhiteSpace(item.NombreProducto) ? "El nombre del producto es obligatorio." : null;
}

public sealed class CategoriasViewModel(INeptunoRepository repository) : CrudViewModel<Categoria>
{
    protected override Task<List<Categoria>> LoadItemsAsync() => repository.ListarCategoriasAsync();
    protected override Task<int> InsertAsync(Categoria item) => repository.CrearCategoriaAsync(item);
    protected override Task UpdateAsync(Categoria item) => repository.ActualizarCategoriaAsync(item);
    protected override Task DeletePersistedAsync(int id) => repository.EliminarCategoriaAsync(id);
    protected override Categoria CreateNew() => new();
    protected override int GetId(Categoria item) => item.IdCategoria;
    protected override void SetId(Categoria item, int id) => item.IdCategoria = id;
    protected override string? Validate(Categoria item) => string.IsNullOrWhiteSpace(item.NombreCategoria) ? "El nombre de la categoría es obligatorio." : null;
}

public sealed partial class ProveedoresViewModel(INeptunoRepository repository) : CrudViewModel<Proveedor>
{
    [ObservableProperty] private string? filtroContacto;
    [ObservableProperty] private string? filtroCiudad;
    public IAsyncRelayCommand SearchCommand => LoadCommand;

    protected override Task<List<Proveedor>> LoadItemsAsync() => repository.BuscarProveedoresAsync(FiltroContacto, FiltroCiudad);
    protected override Task<int> InsertAsync(Proveedor item) => repository.CrearProveedorAsync(item);
    protected override Task UpdateAsync(Proveedor item) => repository.ActualizarProveedorAsync(item);
    protected override Task DeletePersistedAsync(int id) => repository.EliminarProveedorAsync(id);
    protected override Proveedor CreateNew() => new();
    protected override int GetId(Proveedor item) => item.IdProveedor;
    protected override void SetId(Proveedor item, int id) => item.IdProveedor = id;
    protected override string? Validate(Proveedor item) => string.IsNullOrWhiteSpace(item.NombreCompania) ? "El nombre de la compañía es obligatorio." : null;
}

public sealed class PedidosViewModel(INeptunoRepository repository) : CrudViewModel<Pedido>
{
    protected override Task<List<Pedido>> LoadItemsAsync() => repository.ListarPedidosAsync();
    protected override Task<int> InsertAsync(Pedido item) => repository.CrearPedidoAsync(item);
    protected override Task UpdateAsync(Pedido item) => repository.ActualizarPedidoAsync(item);
    protected override Task DeletePersistedAsync(int id) => repository.EliminarPedidoAsync(id);
    protected override Pedido CreateNew() => new();
    protected override int GetId(Pedido item) => item.IdPedido;
    protected override void SetId(Pedido item, int id) => item.IdPedido = id;
    protected override string? Validate(Pedido item) => item.FechaPedido is null ? "La fecha del pedido es obligatoria." : null;
}
