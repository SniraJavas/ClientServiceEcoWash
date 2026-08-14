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

        public async Task<Guid> Handle(RegisterClientCommand cmd, CancellationToken ct)
        {
           return await Task.FromResult(id);
        }
    }
}