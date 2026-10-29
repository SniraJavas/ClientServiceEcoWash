using System;
using System.Collections.Generic;
using System.Text;

namespace Identity.Application.ValueObject
{
    public record RegisterBody(string Email, string Password);
}
