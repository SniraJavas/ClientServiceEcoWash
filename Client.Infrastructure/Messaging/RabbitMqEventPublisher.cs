using Client.Application.Interfaces;
using RabbitMQ.Client;
using System;
using System.Text;
using System.Text.Json;
using System.Threading;
using System.Threading.Tasks;
using static System.Net.Mime.MediaTypeNames;

namespace Client.Infrastructure.Messaging
{
    public class RabbitMqEventPublisher : IEventPublisher
    {
        private readonly IConnection _connection;

        public RabbitMqEventPublisher(IConnection connection)
        {
            _connection = connection
                ?? throw new ArgumentNullException(nameof(connection));
        }

        public async Task PublishAsync(
            object @event,
            CancellationToken ct)
        {
            if (@event == null)
            {
                throw new ArgumentNullException(nameof(@event));
            }

            var exchange = ResolveExchange(@event.GetType());

            await using var channel =
                await _connection.CreateChannelAsync(
                    cancellationToken: ct);

            await channel.ExchangeDeclareAsync(
                exchange: exchange,
                type: ExchangeType.Fanout,
                durable: true,
                cancellationToken: ct);

            var json = JsonSerializer.Serialize(
                @event,
                @event.GetType());

            var body = Encoding.UTF8.GetBytes(json);

            var properties = new BasicProperties
            {
                Persistent = true,
                ContentType = "application/json",
                Type = @event.GetType().Name
            };

            await channel.BasicPublishAsync(
                exchange: exchange,
                routingKey: string.Empty,
                mandatory: false,
                basicProperties: properties,
                body: body,
                cancellationToken: ct);
        }

        public async Task PublishAsync<T>(
            T domainEvent,
            CancellationToken ct)
        {
            if (domainEvent == null)
            {
                throw new ArgumentNullException(nameof(domainEvent));
            }

            var exchange = ResolveExchange<T>();

            await using var channel =
                await _connection.CreateChannelAsync(
                    cancellationToken: ct);

            await channel.ExchangeDeclareAsync(
                exchange: exchange,
                type: ExchangeType.Fanout,
                durable: true,
                cancellationToken: ct);

            var json = JsonSerializer.Serialize(domainEvent);

            var body = Encoding.UTF8.GetBytes(json);

            var properties = new BasicProperties
            {
                Persistent = true,
                ContentType = "application/json",
                Type = typeof(T).Name
            };

            await channel.BasicPublishAsync(
                exchange: exchange,
                routingKey: string.Empty,
                mandatory: false,
                basicProperties: properties,
                body: body,
                cancellationToken: ct);
        }

        private static string ResolveExchange(Type eventType)
        {
            return eventType.Name switch
            {
                "WashRequestedEvent" => "wash-requests",

                "ClientRegisteredEvent" =>  "client-lifecycle",

                _ => throw new InvalidOperationException( $"No RabbitMQ exchange is mapped for event type " + $"'{eventType.Name}'. Add it to ResolveExchange.")
            };
        }

        private static string ResolveExchange<T>()
        {
            return typeof(T).Name switch
            {
                "WashRequestedEvent" =>
                    "wash-requests",

                "ClientRegisteredEvent" =>
                    "client-lifecycle",

                _ => throw new InvalidOperationException(
                    $"No RabbitMQ exchange is mapped for event type " +
                    $"'{typeof(T).Name}'. Add it to ResolveExchange.")
            };
        }
    }
}