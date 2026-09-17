namespace WPF_SP.Data;

public static class DbConfig
{
    // La captura de SSMS muestra una instancia predeterminada local.
    // El punto (.) resuelve al nombre del equipo sin depender de que este cambie.
    public const string ConnectionString =
        @"Server=.;Database=NeptunoDB;Integrated Security=True;TrustServerCertificate=True;Connect Timeout=10;";
}
