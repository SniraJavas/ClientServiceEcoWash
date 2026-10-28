using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using System;
using System.Collections.Generic;
using System.Text;
using Client.Domain.ValueObject;
using ClientEntity = Client.Domain.Entities.Client;

namespace Client.Infrastructure.Persistence.Configurations
{
    public class ClientConfiguration : IEntityTypeConfiguration<ClientEntity>
    {
        public void Configure(EntityTypeBuilder<ClientEntity> builder)
        {
            builder.ToTable("clients");
            builder.HasKey(c => c.Id);

            builder.Property(c => c.IdentitySubjectId).IsRequired();
            builder.HasIndex(c => c.IdentitySubjectId).IsUnique();

            builder.Property(c => c.FullName).IsRequired().HasMaxLength(200);

            builder.Property(c => c.Email)
                .HasConversion(e => e.Value, v => new Email(v))
                .IsRequired().HasMaxLength(320);
            builder.HasIndex(c => c.Email).IsUnique();

            builder.Property(c => c.Phone)
                .HasConversion(p => p.Value, v => new PhoneNumber(v))
                .IsRequired().HasMaxLength(20);

            builder.HasMany(c => c.Vehicles)
                .WithOne()
                .HasForeignKey(v => v.ClientId)
                .OnDelete(DeleteBehavior.Cascade);
            builder.Navigation(c => c.Vehicles)
                .HasField("_vehicles")
                .UsePropertyAccessMode(PropertyAccessMode.Field);

            builder.HasMany(c => c.Addresses)
                .WithOne()
                .HasForeignKey(a => a.ClientId)
                .OnDelete(DeleteBehavior.Cascade);
            builder.Navigation(c => c.Addresses)
                .HasField("_addresses")
                .UsePropertyAccessMode(PropertyAccessMode.Field);
        }
    }
}
