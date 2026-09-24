using Client.Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Infrastructure.Persistence.Configurations
{
    public class VehicleConfiguration : IEntityTypeConfiguration<Vehicle>
    {
        public void Configure(EntityTypeBuilder<Vehicle> builder)
        {
            builder.ToTable("vehicles");
            builder.HasKey(v => v.Id);
            builder.Property(v => v.Make).IsRequired().HasMaxLength(100);
            builder.Property(v => v.Model).IsRequired().HasMaxLength(100);
            builder.Property(v => v.Plate).IsRequired().HasMaxLength(20);
            builder.HasIndex(v => new { v.ClientId, v.Plate }).IsUnique();
        }
    }
}
