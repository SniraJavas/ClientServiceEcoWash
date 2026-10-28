using Client.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Infrastructure.Persistence.Configurations
{
    public class ClientBookingSummaryConfiguration : IEntityTypeConfiguration<ClientBookingSummary>
    {
        public void Configure(EntityTypeBuilder<ClientBookingSummary> builder)
        {
            builder.ToTable("client_booking_history"); // read-model, no FK into clients table
            builder.HasKey(b => b.Id);
            builder.Property(b => b.Status).IsRequired().HasMaxLength(30);
            builder.HasIndex(b => new { b.ClientId, b.RequestedTime });
        }
    }
}
