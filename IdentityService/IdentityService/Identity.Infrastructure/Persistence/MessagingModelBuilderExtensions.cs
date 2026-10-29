using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using System;
using System.Collections.Generic;
using System.Text;

namespace Identity.Infrastructure.Persistence
{

  

    public static class MessagingModelBuilderExtensions
    {
        public static ModelBuilder AddMessagingTables(
            this ModelBuilder builder)
        {
            // Register the outbox and inbox entity mappings here.
            // The entity classes must exist in your project.

            return builder;
        }

        public static void UseAppAssignedGuidKeys(this ModelBuilder b)
        {
            foreach (var entity in b.Model.GetEntityTypes())
            {
                var key = entity.FindPrimaryKey();
                if (key is { Properties.Count: 1 } && key.Properties[0].ClrType == typeof(Guid))
                    key.Properties[0].ValueGenerated = ValueGenerated.Never;   // a property, not a method
            }
        }
    }

}
