using Azure.Identity;

namespace Fakebook.IoCExtensions;

public static class ConfigurationManagerExtensions
{
    public static IConfiguration AddCustomAzureAppConfiguration(this ConfigurationManager configuration)
    {
        // TODO: make this a config value or something 
        var endpoint = "https://csp-ws2023-config-store.azconfig.io";

        // https://learn.microsoft.com/en-us/azure/azure-app-configuration/howto-integrate-azure-managed-service-identity?tabs=core6x&pivots=framework-dotnet
        configuration.AddAzureAppConfiguration(options =>
        {
            options.Connect(new Uri(endpoint), new DefaultAzureCredential());
        });

        return configuration;
    }

    public static IConfiguration AddCustomAzureKeyVault(this ConfigurationManager configuration)
    {
        var endpoint = "https://csp-ws2023-key-vault.vault.azure.net";

        configuration.AddAzureKeyVault(new Uri(endpoint), new DefaultAzureCredential());

        return configuration;
    }
}

