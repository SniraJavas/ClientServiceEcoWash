using Identity.Application;
using Identity.Application.ValueObject;
using System;
using System.Collections.Generic;
using System.Text;

namespace Identity.Infrastructure.Outbox
{
    public class OutboxMessage
    {
   
            public Guid Id { get; set; }

            public string Type { get; set; } = string.Empty;

            public string Payload { get; set; } = string.Empty;

            public DateTime OccurredOnUtc { get; set; }

            public DateTime? ProcessedOnUtc { get; set; }
        
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
