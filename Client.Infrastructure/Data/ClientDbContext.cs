using Microsoft.EntityFrameworkCore;

namespace Client.Infrastructure
{
    public class ClientDbContext : DbContext
    {
        public ClientDbContext(DbContextOptions<ClientDbContext> options) : base(options)
        {
        }

        public DbSet<Client.Domain.Entities.Client> Clients { get; set; } = null!;
    }
}
