namespace Client.Domain.ValueObject
{
    public class Email
    {
        public string Value { get; }

        public Email(string value)
        {
            Value = value ?? string.Empty;
        }
    }
}