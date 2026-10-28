using Client.Api.Contracts;
using Client.Api.Extension;
using Client.Application.Commands;
using Client.Domain.ValueObject;
using MediatR;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace Client.Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ClientRegistrationController : ControllerBase
    {

        private readonly IMediator _mediator;
        public ClientRegistrationController(IMediator mediator) => _mediator = mediator;

        [HttpPost("register")]
        [Authorize(Policy = "RegistrationToken")]
        public async Task<IActionResult> Register(RegisterClientBody body)
        {
            var subjectId = User.GetIdentitySubjectId(); // claim on the registration token
            var id = await _mediator.Send(new RegisterClientCommand(
                subjectId,  
                body.FullName,
                new Email(body.Email),
                new PhoneNumber(body.Phone)));
            return Created($"/api/clients/{id}", new { clientId = id });
        }

    }
}
