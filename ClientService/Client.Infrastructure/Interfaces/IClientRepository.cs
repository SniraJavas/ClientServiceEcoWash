using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Infrastructure.Interfaces
{
    public interface IClientRepository
    {
        Task<Client.Domain.Entities.Client?> GetByIdAsync(Guid id, CancellationToken ct);
        Task<Client.Domain.Entities.Client?> GetByIdentitySubjectAsync(Guid identitySubjectId, CancellationToken ct);
        Task SaveAsync(Client.Domain.Entities.Client client, CancellationToken ct);
    }
}
