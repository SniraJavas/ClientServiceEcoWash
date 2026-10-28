using Client.Domain.Rules;
using Client.Domain.ValueObject;

namespace Client.Domain.Entities
{
    public class Client
    {
        public Guid Id { get; private set; }
        public Guid IdentitySubjectId { get; private set; }
        public string FullName { get; private set; }
        public Email Email { get; private set; }
        public PhoneNumber Phone { get; private set; }
        public bool IsVerified { get; private set; }

        private readonly List<Vehicle> _vehicles = new();
        public IReadOnlyCollection<Vehicle> Vehicles => _vehicles.AsReadOnly();

        private readonly List<Address> _addresses = new();
        public IReadOnlyCollection<Address> Addresses => _addresses.AsReadOnly();

        public static Client Register(
            string fullName, Email email, PhoneNumber phone, Guid identitySubjectId)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                throw new DomainException("Full name is required.");

            return new Client
            {
                Id = Guid.NewGuid(),
                IdentitySubjectId = identitySubjectId,
                FullName = fullName,
                Email = email,
                Phone = phone,
                IsVerified = false
            };
        }

        public void MarkVerified() => IsVerified = true;

        public void UpdateProfile(string fullName, PhoneNumber phone)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                throw new DomainException("Full name is required.");
            FullName = fullName;
            Phone = phone;
        }

        public void AddVehicle(Vehicle vehicle)
        {
            if (_vehicles.Count >= 5)
                throw new DomainException("A client may register at most 5 vehicles.");
            vehicle.AssignToClient(Id);
            _vehicles.Add(vehicle);
        }

        public void AddAddress(Address address)
        {
            if (address.IsDefault)
                foreach (var a in _addresses) { /* only one default at a time */ }
            address.AssignToClient(Id);
            _addresses.Add(address);
        }
    }

}
