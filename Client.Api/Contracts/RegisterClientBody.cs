namespace Client.Api.Contracts
{
    public class RegisterClientBody
    {
        public string FullName { get; init; }
        public string Email { get; init; }
        public string Phone { get; init; }

        public RegisterClientBody(string fullName, string email, string phone)
        {
            FullName = fullName;
            Email = email;
            Phone = phone;              
        }
    }
}
