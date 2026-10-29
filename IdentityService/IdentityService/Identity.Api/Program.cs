using Identity.Infrastructure;
using Identity.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using static OpenIddict.Abstractions.OpenIddictConstants;


using static OpenIddict.Abstractions.OpenIddictConstants;

var builder = WebApplication.CreateBuilder(args);


builder.Services.AddControllers();

builder.Services.AddDbContext<IdentityServiceDbContext>(o =>
{
    o.UseNpgsql(builder.Configuration.GetConnectionString("IdentityDb"));
    o.UseOpenIddict();
});

builder.Services.AddIdentity<AppUser, IdentityRole<Guid>>(o =>
{
    o.User.RequireUniqueEmail = true;
    o.Password.RequiredLength = 10;
    o.Lockout.MaxFailedAccessAttempts = 5;
    o.Lockout.DefaultLockoutTimeSpan = TimeSpan.FromMinutes(15);
    o.ClaimsIdentity.UserNameClaimType = Claims.Name;
    o.ClaimsIdentity.UserIdClaimType = Claims.Subject;
    o.ClaimsIdentity.RoleClaimType = Claims.Role;
    o.ClaimsIdentity.EmailClaimType = Claims.Email;
})
    .AddEntityFrameworkStores<IdentityServiceDbContext>()
    .AddDefaultTokenProviders();

builder.Services.AddOpenIddict()
    .AddCore(o => o.UseEntityFrameworkCore().UseDbContext<IdentityServiceDbContext>())
    .AddServer(o =>
    {
        o.SetIssuer(new Uri(builder.Configuration["Identity:Issuer"]!));
        o.SetTokenEndpointUris("connect/token");
        o.AllowPasswordFlow().AllowRefreshTokenFlow();
        o.RegisterScopes(Scopes.OfflineAccess, "client", "complete-profile");
        o.SetAccessTokenLifetime(TimeSpan.FromMinutes(15));
        o.SetRefreshTokenLifetime(TimeSpan.FromDays(14));
        o.DisableAccessTokenEncryption();              // plain signed JWT
        o.AddDevelopmentEncryptionCertificate()        // dev only: use real keys in production
         .AddDevelopmentSigningCertificate();
        o.UseAspNetCore().EnableTokenEndpointPassthrough();
    });

builder.Services.AddHostedService<OpenIddictSeeder>();


// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}
// ...


app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
