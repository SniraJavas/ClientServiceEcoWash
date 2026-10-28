using Client.Domain.Entities;

namespace Client.Application.Requests.Commands
{
    internal class WashRequestedEvent
    {
        private Guid requestId;
        private Guid clientId;
        private Guid vehicleId;
        private Address location;
        private DateTime requestedTime;
        private string idempotencyKey;

        public WashRequestedEvent(Guid requestId, Guid clientId, Guid vehicleId, Address location, DateTime requestedTime, string idempotencyKey)
        {
            this.requestId = requestId;
            this.clientId = clientId;
            this.vehicleId = vehicleId;
            this.location = location;
            this.requestedTime = requestedTime;
            this.idempotencyKey = idempotencyKey;
        }
    }
}