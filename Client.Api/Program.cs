using Client.Application.Interfaces;
using Client.Infrastructure;
using Client.Infrastructure.Messaging;
using Client.Infrastructure.Persistence;
using Client.Infrastructure.Repositories;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.Services.AddScoped<IClientRepository, ClientRepository>();
builder.Services.AddSingleton<IEventPublisher, RabbitMqEventPublisher>(); // holds a live RabbitMQ connection — must be Singleton

builder.Services.AddDbContext<Client.Infrastructure.Persistence.ClientDbContext>(opt =>
    opt.UseNpgsql(builder.Configuration.GetConnectionString("ClientDb")));

// Client.Api re-checks the token itself, even though Ocelot already validated it at the gateway.
// This is what actually populates User.Claims so the policies below have something to check.
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = builder.Configuration["Identity:Authority"]; // e.g. https://identity-service
        options.Audience = builder.Configuration["Identity:Audience"];   // e.g. "client"
    });

builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("ClientScope", p => p.RequireClaim("scope", "client"));
    options.AddPolicy("RegistrationToken", p => p.RequireClaim("scope", "complete-profile"));
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference(); // browsable UI at /scalar/v1
}

app.UseHttpsRedirection();

app.UseAuthentication(); // must run before UseAuthorization, and was missing entirely
app.UseAuthorization();

app.MapControllers();

app.Run();