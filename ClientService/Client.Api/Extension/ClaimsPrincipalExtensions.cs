using System.Security.Claims;

namespace Client.Api.Extension
{
    public static class ClaimsPrincipalExtensions
    {
        public static Guid GetIdentitySubjectId(this ClaimsPrincipal user)
        {
            var value = user.FindFirstValue(ClaimTypes.NameIdentifier)
                        ?? user.FindFirstValue("sub")
                        ?? throw new UnauthorizedAccessException("Token has no subject claim.");

            return Guid.Parse(value);
        }

        public static Guid GetClientId(this ClaimsPrincipal user)
        {
            var value = user.FindFirstValue("client_id")
                        ?? throw new UnauthorizedAccessException("Token has no client_id claim.");

            return Guid.Parse(value);
        }
    }
}
