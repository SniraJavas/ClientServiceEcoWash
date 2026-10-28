using Client.Application.Interfaces;
using Client.Domain.Entities;
using Client.Domain.Rules;
using MediatR;
using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Application.Requests.Commands
{
  // src/Client.Application/Requests/Commands/CreateWashRequest.cs
public record CreateWashRequestCommand(
    Guid ClientId,
    Guid VehicleId,
    Address Location,
    DateTime RequestedTime,
    string IdempotencyKey) : IRequest<Guid>;
    public class CreateWashRequestHandler : IRequestHandler<CreateWashRequestCommand, Guid>
    {
        private readonly IClientRepository _clients;
        private readonly IEventPublisher _events;
        public async Task<Guid> Handle(CreateWashRequestCommand cmd, CancellationToken ct)
        {
            var client = await _clients.GetByIdAsync(cmd.ClientId, ct)
                ?? throw new NotFoundException("Client not found.");
            if (!client.IsVerified)
                throw new DomainException("Unverified clients cannot request a wash.");
            var vehicle = client.Vehicles.SingleOrDefault(v => v.Id == cmd.VehicleId)
                ?? throw new DomainException("Vehicle does not belong to this client.");
            var requestId = Guid.NewGuid();
            await _events.PublishAsync(new WashRequestedEvent(
                requestId, cmd.ClientId, cmd.VehicleId, cmd.Location,
                cmd.RequestedTime, cmd.IdempotencyKey), ct);
            return requestId;
        }
    }
}
