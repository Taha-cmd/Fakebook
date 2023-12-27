using Azure.Core.Pipeline;
using Azure.Identity;
using Microsoft.EntityFrameworkCore;

namespace Fakebook.IoCExtensions;

public static class ServiceCollectionDatabaseExtensions
{
    public static IServiceCollection AddDatabase(this IServiceCollection serviceCollection, IConfiguration configuration)
    {
        var server = configuration["PG_HOST"];
        var database = configuration["PG_DATABASE"];
        var userId = configuration["PG_USER"];

        var azureTokenProvider = new DefaultAzureCredential();

        Console.WriteLine($"Retrieving token for user '{userId}' for database '{database}' from server '{server}'");

        // TOKEN WILL EXPIRE AT SOME POINT! refresh mechanism is required for production code
        var tokenRequest = azureTokenProvider.GetToken(new(["https://ossrdbms-aad.database.windows.net/.default"]));
        var connectionString = $"Server={server};Database={database};Port=5432;User Id={userId};Password={tokenRequest.Token};Ssl Mode=Require;";

        // https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-connect-with-managed-identity
        serviceCollection.AddDbContext<FakebookDbContext>(options =>
        {

            options.UseNpgsql(connectionString, postgresOptions =>
            {

            });
        });


        return serviceCollection;
    }

    public static IServiceCollection AddRedisCache(this IServiceCollection serviceCollection, IConfiguration configuration)
    {
        // Using Redis with Azure Authentication would be super easy as there is a package for it: https://github.com/Azure/Microsoft.Azure.StackExchangeRedis
        // However, Azure Authentication on Redis is only supported for Enterprise SKUs

        var connectionString = configuration["redis-connection-string"] ?? throw new ArgumentException("redis connection string configuration value 'redis-connection-string' not found");

        Console.WriteLine("Adding redis cache");
        // https://nishanc.medium.com/redis-as-a-distributed-cache-on-net-6-0-949ef5b795ee
        serviceCollection.AddStackExchangeRedisCache(options =>
        {
            // Let's confuse people and call the connection string 'Configuration', because why not
            options.Configuration = connectionString;
            options.InstanceName = "Fakebook_";
        });

        return serviceCollection;
    }
}

