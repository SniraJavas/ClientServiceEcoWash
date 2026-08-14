namespace Client.Application.Interfaces
{
    public interface IEventPublisher
    {
        Task PublishAsync(object @event, CancellationToken ct);
    }
}