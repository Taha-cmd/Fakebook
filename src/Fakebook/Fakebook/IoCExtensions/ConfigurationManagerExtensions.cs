using Azure.Identity;

namespace Fakebook.IoCExtensions;

public static class ConfigurationManagerExtensions
{
    public static IConfiguration AddCustomAzureAppConfiguration(this ConfigurationManager configuration)
    {

        var endpoint = configuration["CONFIG_STORE_ENDPOINT"] ?? throw new ArgumentException("Env var 'CONFIG_STORE_ENDPOINT' is missing");
        Console.WriteLine($"Connecting to config store: '{endpoint}'");

        // https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-integrate-azure-managed-service-identity?tabs=core6x&pivots=framework-dotnet
        configuration.AddAzureAppConfiguration(options =>
        {
            options.Connect(new Uri(endpoint), new DefaultAzureCredential());
        });

        return configuration;
    }

    public static IConfiguration AddCustomAzureKeyVault(this ConfigurationManager configuration)
    {
        var endpoint = configuration["KEY_VAULT_ENDPOINT"] ?? throw new ArgumentException("Env var 'KEY_VAULT_ENDPOINT' is missing");
        Console.WriteLine($"Connecting to key vault: '{endpoint}'");

        configuration.AddAzureKeyVault(new Uri(endpoint), new DefaultAzureCredential());

        return configuration;
    }
}

