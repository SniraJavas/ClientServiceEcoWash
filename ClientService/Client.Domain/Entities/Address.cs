using System;
using System.Collections.Generic;
using System.Text;

namespace Client.Domain.Entities
{
    public class Address
    {
        public Guid Id { get; private set; }
        public Guid ClientId { get; private set; }
        public string Label { get; private set; }       // "Home", "Work"
        public string Street { get; private set; }
        public string City { get; private set; }
        public string PostalCode { get; private set; }
        public bool IsDefault { get; private set; }

        private Address() { } // EF Core

        public static Address Create(string label, string street, string city, string postalCode, bool isDefault = false) => new()
        {
            Id = Guid.NewGuid(),
            Label = label,
            Street = street,
            City = city,
            PostalCode = postalCode,
            IsDefault = isDefault
        };

        internal void AssignToClient(Guid clientId) => ClientId = clientId;
        public void MarkAsDefault() => IsDefault = true;
    }
}
