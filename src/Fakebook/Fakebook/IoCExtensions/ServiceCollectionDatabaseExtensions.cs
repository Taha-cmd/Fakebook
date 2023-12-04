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
        //var userId = configuration["PG_USER"];
        var userId = "04b07795-8ddb-461a-bbee-02f9e1bf7b46";

        var azureTokenProvider = new DefaultAzureCredential();
        //var azureTokenProvider = new ManagedIdentityCredential(userId, tokenOptions);

        // TOKEN WILL EXPIRE AT SOME POINT! refresh mechanism is required for production code
        var tokenRequest = azureTokenProvider.GetToken(new(new[] { "https://ossrdbms-aad.database.windows.net/.default" }));

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
}

