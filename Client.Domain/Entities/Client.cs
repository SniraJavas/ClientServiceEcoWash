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

        public void AddVehicle(Vehicle vehicle)
        {
            if (_vehicles.Count >= 5)
                throw new DomainException("A client may register at most 5 vehicles.");
            _vehicles.Add(vehicle);
        }
    }

}
