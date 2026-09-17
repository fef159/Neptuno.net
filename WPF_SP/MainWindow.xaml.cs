using System.Windows;
using WPF_SP.Data;
using WPF_SP.ViewModels;

namespace WPF_SP;

public partial class MainWindow : Window
{
    private readonly MainViewModel _viewModel;

    public MainWindow()
    {
        InitializeComponent();
        INeptunoRepository repository = new NeptunoRepository(DbConfig.ConnectionString);
        _viewModel = new MainViewModel(repository);
        DataContext = _viewModel;
        Loaded += async (_, _) => await _viewModel.CargarTodoCommand.ExecuteAsync(null);
    }
}
