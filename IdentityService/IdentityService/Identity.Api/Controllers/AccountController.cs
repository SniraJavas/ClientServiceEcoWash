using Identity.Application;
using Identity.Application.ValueObject;
using Identity.Infrastructure.Outbox;
using Identity.Infrastructure.Persistence;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;

namespace Identity.Api.Controllers
{
    //public record RegisterBody(string Email, string Password);
    //public record EmailVerificationRequestedEvent(Guid UserId, string Email, string VerificationLink);
    //public record EmailVerifiedEvent(Guid IdentitySubjectId, DateTime VerifiedAt);

    [ApiController]
    public class AccountController : ControllerBase
    {
        private readonly UserManager<AppUser> _users;
        private readonly IdentityServiceDbContext _db;
        private readonly IConfiguration _cfg;
        public AccountController(UserManager<AppUser> u, IdentityServiceDbContext db,
            IConfiguration cfg)
        { _users = u; _db = db; _cfg = cfg; }

        [HttpPost("~/connect/register")]
        public async Task<IActionResult> Register(RegisterBody body, CancellationToken ct)
        {
            var user = new AppUser { Id = Guid.NewGuid(), UserName = body.Email, Email = body.Email };

            await using var tx = await _db.Database.BeginTransactionAsync(ct);
            var created = await _users.CreateAsync(user, body.Password);
            if (!created.Succeeded)
                return ValidationProblem(new ValidationProblemDetails(
                    created.Errors.ToDictionary(e => e.Code, e => new[] { e.Description })));

            var token = await _users.GenerateEmailConfirmationTokenAsync(user);
            var link = $"{_cfg["Identity:PublicBaseUrl"]}/auth/verify-email" +
                       $"?userId={user.Id}&token={Uri.EscapeDataString(token)}";
            _db.OutboxMessages.Add(OutboxMessage.From(
                new EmailVerificationRequestedEvent(user.Id, user.Email!, link)));
            await _db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);

            return Created($"/connect/users/{user.Id}", new { userId = user.Id });
        }

        [HttpGet("~/connect/verify-email")]
        public async Task<IActionResult> VerifyEmail(Guid userId, string token, CancellationToken ct)
        {
            var user = await _users.FindByIdAsync(userId.ToString());
            if (user is null) return BadRequest("The link is invalid or has expired.");

            await using var tx = await _db.Database.BeginTransactionAsync(ct);
            var result = await _users.ConfirmEmailAsync(user, token);
            if (!result.Succeeded) return BadRequest("The link is invalid or has expired.");

            _db.OutboxMessages.Add(OutboxMessage.From(
                new EmailVerifiedEvent(user.Id, DateTime.UtcNow)));
            await _db.SaveChangesAsync(ct);
            await tx.CommitAsync(ct);
            return Ok("Email verified. You can now sign in.");
        }
    }
}
