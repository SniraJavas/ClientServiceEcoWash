
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;

var builder = WebApplication.CreateBuilder(args);

// Load Ocelot configuration
builder.Configuration.AddJsonFile(
    "ocelot.json",
    optional: false,
    reloadOnChange: true);

// Authentication
builder.Services
    .AddAuthentication()
    .AddJwtBearer("ClientAuth", options =>
    {
        options.Authority =
            builder.Configuration["Identity:Issuer"];

        options.RequireHttpsMetadata =
            !builder.Environment.IsDevelopment();

        // Configure this only when the IdentityService
        // actually issues tokens containing this audience.
        options.Audience =
            builder.Configuration["Identity:Audience"];
    });

// Authorization
builder.Services.AddAuthorization();

// Ocelot
builder.Services.AddOcelot(builder.Configuration);

var app = builder.Build();

app.UseAuthentication();
app.UseAuthorization();

await app.UseOcelot();

await app.RunAsync();
