using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Domain.Entities
{
    public class ClientBookingSummary
    {
        public Guid Id { get; private set; }          // booking id
        public Guid ClientId { get; private set; }
        public Guid VehicleId { get; private set; }
        public DateTime RequestedTime { get; private set; }
        public string Status { get; private set; }    // Requested, Matched, Completed, Cancelled
        public DateTime UpdatedAtUtc { get; private set; }

        private ClientBookingSummary() { } // EF Core

        public ClientBookingSummary(Guid bookingId, Guid clientId, Guid vehicleId, DateTime requestedTime, string status)
        {
            Id = bookingId;
            ClientId = clientId;
            VehicleId = vehicleId;
            RequestedTime = requestedTime;
            Status = status;
            UpdatedAtUtc = DateTime.UtcNow;
        }

        public void UpdateStatus(string status)
        {
            Status = status;
            UpdatedAtUtc = DateTime.UtcNow;
        }
    }
}
