using Client.Domain.Entities;
using ClientEntity = Client.Domain.Entities.Client;

namespace Client.Application.Interfaces
{
    public interface IClientRepository
    {   
        Task<ClientEntity?> GetByIdAsync(Guid id, CancellationToken ct);
        Task<ClientEntity?> GetByIdentitySubjectAsync(Guid identitySubjectId, CancellationToken ct);
        Task SaveAsync(ClientEntity client, CancellationToken ct);
    }
}