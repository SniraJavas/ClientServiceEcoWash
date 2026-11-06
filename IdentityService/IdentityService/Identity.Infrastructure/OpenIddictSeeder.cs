using Identity.Infrastructure.Persistence;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using OpenIddict.Abstractions;
using System;
using System.Collections.Generic;
using System.Text;
using static OpenIddict.Abstractions.OpenIddictConstants;

namespace Identity.Infrastructure
{
    public class OpenIddictSeeder : IHostedService
    {
        private readonly IServiceProvider _sp;
        public OpenIddictSeeder(IServiceProvider sp) => _sp = sp;

        public async Task StartAsync(CancellationToken ct)
        {

            using var scope = _sp.CreateScope();

            var dbContext = scope.ServiceProvider
                .GetRequiredService<IdentityServiceDbContext>();

            var connection = dbContext.Database.GetDbConnection();

            var builder = new Npgsql.NpgsqlConnectionStringBuilder(
                connection.ConnectionString);

            //Console.WriteLine("========== ECOWASH DATABASE DEBUG ==========");
            //Console.WriteLine($"Database: {builder.Database}");
            //Console.WriteLine($"Host: {builder.Host}");
            //Console.WriteLine($"Port: {builder.Port}");
            //Console.WriteLine($"Username: {builder.Username}");
            //Console.WriteLine($"Password: {builder.Password}");
            //Console.WriteLine("============================================");

            await dbContext.Database.OpenConnectionAsync(ct);

            Console.WriteLine("PostgreSQL connection successful!");

            await dbContext.Database.CloseConnectionAsync();


            //await dbContext.Database.MigrateAsync(ct);

            var apps = scope.ServiceProvider.GetRequiredService<IOpenIddictApplicationManager>();
            if (await apps.FindByClientIdAsync("client-app", ct) is not null) return;

            await apps.CreateAsync(new OpenIddictApplicationDescriptor
            {
                ClientId = "client-app",
                ClientType = ClientTypes.Public,          // mobile/web app, no secret
                DisplayName = "Client app",
                Permissions =
            {
                Permissions.Endpoints.Token,
                Permissions.GrantTypes.Password,
                Permissions.GrantTypes.RefreshToken,
                Permissions.Prefixes.Scope + "client",
                Permissions.Prefixes.Scope + "complete-profile",
                Permissions.Prefixes.Scope + Scopes.OfflineAccess
            }
            }, ct);
        }

        public Task StopAsync(CancellationToken ct) => Task.CompletedTask;
    }
}
