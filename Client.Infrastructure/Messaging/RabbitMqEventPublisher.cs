using Client.Application.Interfaces;
using RabbitMQ.Client;
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;

namespace Client.Infrastructure.Messaging
{
    public class RabbitMqEventPublisher : IEventPublisher, IDisposable
    {
        private readonly IConnection _connection;

        public RabbitMqEventPublisher(IConnection connection)
        {
            _connection = connection;
        }

        // Implement the interface method
        public Task PublishAsync(object @event, CancellationToken ct)
        {
            if (@event == null) throw new ArgumentNullException(nameof(@event));

            var exchange = ResolveExchange(@event.GetType());

            using var channel = _connection.CreateModel();
            channel.ExchangeDeclare(exchange: exchange, type: ExchangeType.Fanout, durable: true);

            var json = JsonSerializer.Serialize(@event, @event.GetType());
            var body = Encoding.UTF8.GetBytes(json);

            var props = channel.CreateBasicProperties();
            props.Persistent = true;
            props.ContentType = "application/json";
            props.Type = @event.GetType().Name; // lets consumers dispatch by event type

            channel.BasicPublish(
                exchange: exchange,
                routingKey: string.Empty, // fanout: routing key is ignored
                basicProperties: props,
                body: body);

            return Task.CompletedTask;
        }

        // Keep the existing generic method (optional reuse)
        public Task PublishAsync<T>(T domainEvent, CancellationToken ct)
        {
            var exchange = ResolveExchange<T>();

            using var channel = _connection.CreateModel();
            channel.ExchangeDeclare(exchange: exchange, type: ExchangeType.Fanout, durable: true);

            var json = JsonSerializer.Serialize(domainEvent);
            var body = Encoding.UTF8.GetBytes(json);

            var props = channel.CreateBasicProperties();
            props.Persistent = true;
            props.ContentType = "application/json";
            props.Type = typeof(T).Name; // lets consumers dispatch by event type

            channel.BasicPublish(
                exchange: exchange,
                routingKey: string.Empty, // fanout: routing key is ignored
                basicProperties: props,
                body: body);

            return Task.CompletedTask;
        }

        // New overload that resolves by runtime Type
        private static string ResolveExchange(Type type) => type.Name switch
        {
            "WashRequestedEvent" => "wash-requests",
            "ClientRegisteredEvent" => "client-lifecycle",
            _ => throw new InvalidOperationException(
                $"No exchange mapped for event type {type.Name}. Add it to ResolveExchange.")
        };

        private static string ResolveExchange<T>() => typeof(T).Name switch
        {
            "WashRequestedEvent" => "wash-requests",
            "ClientRegisteredEvent" => "client-lifecycle",
            _ => throw new InvalidOperationException(
                $"No exchange mapped for event type {typeof(T).Name}. Add it to ResolveExchange.")
        };

        public void Dispose() => _connection?.Dispose();
    }
}