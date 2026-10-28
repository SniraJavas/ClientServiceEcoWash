FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /src

# Copy project files first
COPY Client.Api/Client.Api.csproj Client.Api/
COPY Client.Application/Client.Application.csproj Client.Application/
COPY Client.Domain/Client.Domain.csproj Client.Domain/
COPY Client.Infrastructure/Client.Infrastructure.csproj Client.Infrastructure/

# Restore dependencies
RUN dotnet restore Client.Api/Client.Api.csproj

# Copy source code
COPY Client.Api/ Client.Api/
COPY Client.Application/ Client.Application/
COPY Client.Domain/ Client.Domain/
COPY Client.Infrastructure/ Client.Infrastructure/

# Publish
RUN dotnet publish Client.Api/Client.Api.csproj \
    -c Release \
    -o /app/publish \
    --no-restore


# Runtime image
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final

WORKDIR /app

COPY --from=build /app/publish .

EXPOSE 8080

ENV ASPNETCORE_URLS=http://+:8080

ENTRYPOINT ["dotnet", "Client.Api.dll"]