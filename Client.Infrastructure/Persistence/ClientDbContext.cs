using Client.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Infrastructure.Persistence
{
    public class ClientDbContext : DbContext
    {
        public ClientDbContext(DbContextOptions<ClientDbContext> options) : base(options) { }

        public DbSet<global::Client.Domain.Entities.Client> Clients => Set<global::Client.Domain.Entities.Client>();
        public DbSet<global::Client.Domain.Entities.ClientBookingSummary> BookingHistory => Set<global::Client.Domain.Entities.ClientBookingSummary>();

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.ApplyConfigurationsFromAssembly(typeof(ClientDbContext).Assembly);
        }
    }
}
