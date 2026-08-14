using Client.Application.Interfaces;
using Client.Infrastructure;
using Client.Infrastructure.Messaging;
using Client.Infrastructure.Repositories;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();
builder.Services.AddScoped<IClientRepository, ClientRepository>();
builder.Services.AddScoped<IEventPublisher, RabbitMqEventPublisher>();
builder.Services.AddDbContext<ClientDbContext>(opt =>
    opt.UseNpgsql(builder.Configuration.GetConnectionString("ClientDb")));

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
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
