using Identity.Application;
using Identity.Application.ValueObject;
using System;
using System.Collections.Generic;
using System.Text;

namespace Identity.Infrastructure.Outbox
{
    public class OutboxMessage
    {
        public static OutboxMessage From(EmailVerificationRequestedEvent emailVerificationRequestedEvent)
        {
            throw new NotImplementedException();
        }

        public static OutboxMessage From(EmailVerifiedEvent emailVerifiedEvent)
        {
            throw new NotImplementedException();
        }
    }
}
