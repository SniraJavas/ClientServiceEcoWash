namespace Client.Domain.Entities
{
    public class Vehicle
    {
        public Guid Id { get; private set; }
        public string Make { get; private set; }
        public string Model { get; private set; }
        public string Plate { get; private set; }
        public int Type { get; private set; }

        public static Vehicle Create(string make, string model, string plate, int type)
        {
            if (string.IsNullOrWhiteSpace(make))
                throw new ArgumentException("Make is required.", nameof(make));
            if (string.IsNullOrWhiteSpace(model))
                throw new ArgumentException("Model is required.", nameof(model));
            if (string.IsNullOrWhiteSpace(plate))
                throw new ArgumentException("Plate is required.", nameof(plate));
            if (type < 0)
                throw new ArgumentException("Type must be a non-negative integer.", nameof(type));
            return new Vehicle
            {
                Id = Guid.NewGuid(),
                Make = make,
                Model = model,
                Plate = plate,
                Type = type
            };
        }
    }
}