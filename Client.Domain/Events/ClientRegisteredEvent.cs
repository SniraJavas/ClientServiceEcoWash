using Client.Domain.ValueObject;

namespace Client.Application.Commands
{
    internal class ClientRegisteredEvent
    {
        private Guid id;
        private Guid identitySubjectId;
        private Email email;

        public ClientRegisteredEvent(Guid id, Guid identitySubjectId, Email email)
        {
            this.id = id;
            this.identitySubjectId = identitySubjectId;
            this.email = email;
        }
    }
}