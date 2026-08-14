using Client.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Client.Infrastructure
{
    public class ClientRepository
    {
        private readonly ClientDbContext _db;

        public ClientRepository(ClientDbContext db)
        {
            _db = db ?? throw new ArgumentNullException(nameof(db));
        }

        public async Task<Domain.Entities.Client?> GetByIdAsync(Guid id, CancellationToken ct) =>
          await _db.Clients.Include(c => c.Vehicles)
              .FirstOrDefaultAsync(c => c.Id == id, ct);

        public async Task<Domain.Entities.Client?> GetByIdentitySubjectAsync(Guid identitySubjectId, CancellationToken ct) =>
        await _db.Clients.Include(c => c.Vehicles)
            .FirstOrDefaultAsync(c => c.IdentitySubjectId == identitySubjectId, ct);

        public async Task SaveAsync(Domain.Entities.Client client, CancellationToken ct)
        {
            _db.Clients.Update(client);
            await _db.SaveChangesAsync(ct);
        }



    }
} 
