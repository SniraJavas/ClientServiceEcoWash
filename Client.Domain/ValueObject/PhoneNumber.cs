namespace Client.Domain.ValueObject
{
    public class PhoneNumber
    {       
        public string Value { get; }

        public PhoneNumber(string value)
        {
            Value = value ?? string.Empty;
        }
    }
}