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
            await scope.ServiceProvider.GetRequiredService<IdentityServiceDbContext>()
                .Database.MigrateAsync(ct);   // dev convenience; migrate as a release step in production

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
