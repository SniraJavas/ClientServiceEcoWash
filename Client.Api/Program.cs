using Client.Application.Interfaces;
using Client.Infrastructure.Messaging;
using Client.Infrastructure.Persistence;
using Client.Infrastructure.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using RabbitMQ.Client;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// --- Persistence ---
// ClientDbContext must live in Client.Infrastructure.Persistence (see note below).
builder.Services.AddDbContext<ClientDbContext>(opt =>
    opt.UseNpgsql(builder.Configuration.GetConnectionString("ClientDb")));

builder.Services.AddScoped<IClientRepository, ClientRepository>();

// --- RabbitMQ ---
// The publisher needs an IConnection, so register that first (RabbitMQ.Client 7.x API).
builder.Services.AddSingleton<IConnection>(_ =>
{
    var cfg = builder.Configuration;
    var factory = new ConnectionFactory
    {
        HostName = cfg["RabbitMq:Host"] ?? "localhost",
        Port = int.Parse(cfg["RabbitMq:Port"] ?? "5672"),
        UserName = cfg["RabbitMq:Username"] ?? "guest",
        Password = cfg["RabbitMq:Password"] ?? "guest"
    };

    // On RabbitMQ.Client 6.x use: return factory.CreateConnection();
    return factory.CreateConnectionAsync().GetAwaiter().GetResult();
});

builder.Services.AddSingleton<IEventPublisher, RabbitMqEventPublisher>(); // holds a live connection, must be Singleton

// --- Auth ---
// Client.Api re-checks the token itself, even though Ocelot already validated it at the gateway.
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Identity:Authority"];
        options.Audience = builder.Configuration["Identity:Audience"];
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("ClientScope", p => p.RequireClaim("scope", "client"));
    options.AddPolicy("RegistrationToken", p => p.RequireClaim("scope", "complete-profile"));
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(); // browsable UI at /scalar/v1
}
else
{
    app.UseHttpsRedirection();
}

app.UseAuthentication(); // must run before UseAuthorization
app.UseAuthorization();

app.MapControllers();

app.Run();