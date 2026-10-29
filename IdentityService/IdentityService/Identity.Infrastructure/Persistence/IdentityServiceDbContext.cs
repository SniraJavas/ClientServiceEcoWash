using Identity.Infrastructure.Outbox;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using OpenIddict.EntityFrameworkCore.Models;
using System;
using System.Collections.Generic;
using System.Text;

namespace Identity.Infrastructure.Persistence
{
    public class AppUser : IdentityUser<Guid> { }

    public class IdentityServiceDbContext
        : IdentityDbContext<AppUser, IdentityRole<Guid>, Guid>
    {
        public IdentityServiceDbContext(DbContextOptions<IdentityServiceDbContext> options)
            : base(options) { }

        public DbSet<OutboxMessage> OutboxMessages => Set<OutboxMessage>();

        protected override void OnModelCreating(ModelBuilder b)   // <- this is the method
        {
            base.OnModelCreating(b);   // must stay first: registers ASP.NET Identity's own tables

            b.UseOpenIddict();         // registers OpenIddict's four tables

            // match the table names in schema.sql
            b.Entity<AppUser>().ToTable("users");
            b.Entity<IdentityRole<Guid>>().ToTable("roles");
            b.Entity<IdentityUserRole<Guid>>().ToTable("user_roles");
            b.Entity<IdentityUserClaim<Guid>>().ToTable("user_claims");
            b.Entity<IdentityUserLogin<Guid>>().ToTable("user_logins");
            b.Entity<IdentityRoleClaim<Guid>>().ToTable("role_claims");
            b.Entity<IdentityUserToken<Guid>>().ToTable("user_tokens");
            b.Entity<OpenIddictEntityFrameworkCoreApplication>().ToTable("oidc_applications");
            b.Entity<OpenIddictEntityFrameworkCoreAuthorization>().ToTable("oidc_authorizations");
            b.Entity<OpenIddictEntityFrameworkCoreScope>().ToTable("oidc_scopes");
            b.Entity<OpenIddictEntityFrameworkCoreToken>().ToTable("oidc_tokens");

            b.AddMessagingTables();        // outbox + inbox
            b.UseAppAssignedGuidKeys();    // keep last
        }
    }
}
