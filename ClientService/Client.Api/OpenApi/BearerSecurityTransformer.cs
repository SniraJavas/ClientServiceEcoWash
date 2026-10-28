using Microsoft.AspNetCore.OpenApi;
using Microsoft.OpenApi;

namespace Client.Api.OpenApi
{
    internal sealed class BearerSecurityTransformer : IOpenApiDocumentTransformer
    {
        public Task TransformAsync(OpenApiDocument document,
            OpenApiDocumentTransformerContext context, CancellationToken ct)
        {
            document.Components ??= new OpenApiComponents();
            document.Components.SecuritySchemes = new Dictionary<string, IOpenApiSecurityScheme>
            {
                ["Bearer"] = new OpenApiSecurityScheme
                {
                    Type = SecuritySchemeType.Http,
                    Scheme = "bearer",
                    BearerFormat = "JWT",
                    Description = "Paste the JWT only, without the 'Bearer ' prefix."
                }
            };

            document.Security =
            [
                new OpenApiSecurityRequirement
            {
                [new OpenApiSecuritySchemeReference("Bearer", document)] = []
            }
            ];
            return Task.CompletedTask;
        }
    }
}
