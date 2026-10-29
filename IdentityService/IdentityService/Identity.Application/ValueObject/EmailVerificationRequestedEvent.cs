namespace Identity.Application
{
    public record EmailVerificationRequestedEvent(Guid UserId, string Email, string VerificationLink);
}
