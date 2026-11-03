using System;
using System.Collections.Generic;
using System.Text;

namespace Identity.Infrastructure.Outbox
{

    public class InboxMessage
    {
        public Guid Id { get; set; }

        public string Type { get; set; } = string.Empty;

        public string Payload { get; set; } = string.Empty;

        public DateTime OccurredOnUtc { get; set; }

        public DateTime? ProcessedOnUtc { get; set; }
    }
}
