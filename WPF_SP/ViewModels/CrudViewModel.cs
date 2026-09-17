using System.Collections.ObjectModel;
using CommunityToolkit.Mvvm.ComponentModel;
using CommunityToolkit.Mvvm.Input;

namespace WPF_SP.ViewModels;

public abstract class CrudViewModel<T> : ObservableObject where T : class
{
    private T? _selectedItem;
    private string? _message;
    private bool _isBusy;
    private bool _hasError;

    public ObservableCollection<T> Items { get; } = new();
    public T? SelectedItem { get => _selectedItem; set => SetProperty(ref _selectedItem, value); }
    public string? Message { get => _message; protected set => SetProperty(ref _message, value); }
    public bool IsBusy { get => _isBusy; private set => SetProperty(ref _isBusy, value); }
    public bool HasError { get => _hasError; private set => SetProperty(ref _hasError, value); }

    public IAsyncRelayCommand LoadCommand { get; }
    public IRelayCommand NewCommand { get; }
    public IAsyncRelayCommand SaveCommand { get; }
    public IAsyncRelayCommand DeleteCommand { get; }

    protected CrudViewModel()
    {
        LoadCommand = new AsyncRelayCommand(LoadAsync);
        NewCommand = new RelayCommand(New);
        SaveCommand = new AsyncRelayCommand(SaveAsync);
        DeleteCommand = new AsyncRelayCommand(DeleteAsync);
    }

    protected abstract Task<List<T>> LoadItemsAsync();
    protected abstract Task<int> InsertAsync(T item);
    protected abstract Task UpdateAsync(T item);
    protected abstract Task DeletePersistedAsync(int id);
    protected abstract T CreateNew();
    protected abstract int GetId(T item);
    protected abstract void SetId(T item, int id);
    protected abstract string? Validate(T item);

    public virtual async Task LoadAsync() => await RunAsync(async () =>
    {
        var result = await LoadItemsAsync();
        Items.Clear();
        foreach (var item in result) Items.Add(item);
        SelectedItem = Items.FirstOrDefault();
        Message = $"{Items.Count} registro(s) activo(s).";
    }, "No se pudieron cargar los datos");

    private void New()
    {
        var item = CreateNew();
        Items.Insert(0, item);
        SelectedItem = item;
        Message = "Complete la fila nueva y presione Guardar.";
    }

    private async Task SaveAsync()
    {
        if (SelectedItem is null) { Message = "Seleccione o agregue un registro."; return; }
        var validation = Validate(SelectedItem);
        if (validation is not null) { Message = validation; return; }

        await RunAsync(async () =>
        {
            if (GetId(SelectedItem) == 0)
            {
                SetId(SelectedItem, await InsertAsync(SelectedItem));
                Message = "Registro creado mediante ExecuteNonQuery.";
            }
            else
            {
                await UpdateAsync(SelectedItem);
                Message = "Registro actualizado mediante ExecuteNonQuery.";
            }
        }, "No se pudo guardar el registro");
    }

    private async Task DeleteAsync()
    {
        if (SelectedItem is null) { Message = "Seleccione un registro."; return; }
        var item = SelectedItem;
        await RunAsync(async () =>
        {
            var id = GetId(item);
            if (id != 0) await DeletePersistedAsync(id);
            Items.Remove(item);
            SelectedItem = Items.FirstOrDefault();
            Message = id == 0 ? "Fila nueva descartada." : "Baja lógica realizada: Activo = 0.";
        }, "No se pudo dar de baja el registro");
    }

    protected async Task RunAsync(Func<Task> action, string errorPrefix)
    {
        if (IsBusy) return;
        IsBusy = true;
        HasError = false;
        Message = null;
        try { await action(); }
        catch (Exception ex)
        {
            HasError = true;
            Message = $"{errorPrefix}: {ex.Message}";
        }
        finally { IsBusy = false; }
    }
}
