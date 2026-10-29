using Identity.Infrastructure.Persistence;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using OpenIddict.Abstractions;
using OpenIddict.Server.AspNetCore;
using System.Security.Claims;
using static OpenIddict.Abstractions.OpenIddictConstants;

namespace Identity.Api.Controllers
{
    public class AuthorizationController : Controller
    {
        private readonly UserManager<AppUser> _users;
        private readonly SignInManager<AppUser> _signIn;
        public AuthorizationController(UserManager<AppUser> u, SignInManager<AppUser> s)
        { _users = u; _signIn = s; }

        [HttpPost("~/connect/token"), Produces("application/json")]
        public async Task<IActionResult> Exchange()
        {
            var request = HttpContext.GetOpenIddictServerRequest()
                ?? throw new InvalidOperationException("OpenID Connect request not found.");

            AppUser? user;
            if (request.IsPasswordGrantType())
            {
                user = await _users.FindByEmailAsync(request.Username!);
                if (user is null) return Reject("Invalid email or password.");
                var check = await _signIn.CheckPasswordSignInAsync(
                    user, request.Password!, lockoutOnFailure: true);
                if (!check.Succeeded) return Reject("Invalid email or password.");
            }
            else if (request.IsRefreshTokenGrantType())
            {
                var auth = await HttpContext.AuthenticateAsync(
                    OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
                user = await _users.FindByIdAsync(auth.Principal!.GetClaim(Claims.Subject)!);
                if (user is null || !await _signIn.CanSignInAsync(user))
                    return Reject("The refresh token is no longer valid.");
            }
            else throw new InvalidOperationException("Unsupported grant type.");

            return SignIn(BuildPrincipal(user, request.GetScopes()),
                OpenIddictServerAspNetCoreDefaults.AuthenticationScheme);
        }

        private static ClaimsPrincipal BuildPrincipal(AppUser user, IEnumerable<string> requested)
        {
            var verified = user.EmailConfirmed;
            var allowed = verified
                ? new[] { "client", Scopes.OfflineAccess }
                : new[] { "complete-profile" };
            var granted = requested.Intersect(allowed).ToList();
            if (granted.Count == 0) granted.AddRange(allowed);

            var identity = new ClaimsIdentity("OpenIddict", Claims.Name, Claims.Role);
            identity.SetClaim(Claims.Subject, user.Id.ToString());
            identity.SetClaim(Claims.Email, user.Email);
            identity.SetClaim("email_verified", verified ? "true" : "false");

            var principal = new ClaimsPrincipal(identity);
            principal.SetScopes(granted);
            principal.SetResources("client-api");
            principal.SetDestinations(_ => new[] { Destinations.AccessToken });
            return principal;
        }

        private ForbidResult Reject(string description) => Forbid(
          new AuthenticationProperties(new Dictionary<string, string?>
          {
              [OpenIddictServerAspNetCoreConstants.Properties.Error] = Errors.InvalidGrant,
              [OpenIddictServerAspNetCoreConstants.Properties.ErrorDescription] = description
          }),
          OpenIddictServerAspNetCoreDefaults.AuthenticationScheme // Scheme goes second
      );

    }
}
