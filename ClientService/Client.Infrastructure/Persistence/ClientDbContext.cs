using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Client.Domain.Entities;

using ClientEntity = Client.Domain.Entities.Client;
using ClientBookingSummaryEntity = Client.Domain.Entities.ClientBookingSummary;

namespace Client.Infrastructure.Persistence
{
    public class ClientDbContext : DbContext
    {
        public ClientDbContext(DbContextOptions<ClientDbContext> options) : base(options) { }

        public DbSet<ClientEntity> Clients => Set<ClientEntity>();
        public DbSet<ClientBookingSummaryEntity> BookingHistory => Set<ClientBookingSummaryEntity>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ClientDbContext).Assembly);
        }
    }
}
