using System.IO;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Configuration.Json;

namespace Client.Infrastructure.Persistence
{
    public class ClientDbContextFactory : IDesignTimeDbContextFactory<ClientDbContext>
    {
        public ClientDbContext CreateDbContext(string[] args)
        {
            var config = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true)
                .AddEnvironmentVariables()
                .Build();

            var options = new DbContextOptionsBuilder<ClientDbContext>()
                .UseNpgsql(config.GetConnectionString("ClientDb")
                    ?? "Host=localhost;Database=client_db;Username=postgres;Password=postgres")
                .Options;

            return new ClientDbContext(options);
        }
    }
}