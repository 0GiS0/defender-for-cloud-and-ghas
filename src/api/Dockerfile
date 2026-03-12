# INSECURE: Using latest tag - no version pinning
FROM mcr.microsoft.com/dotnet/sdk:latest

# INSECURE: No non-root user configured
WORKDIR /app

# INSECURE: Copying everything including unnecessary files
COPY . .

# INSECURE: Exposing debug port
EXPOSE 80
EXPOSE 443
EXPOSE 5000
EXPOSE 5001

RUN dotnet restore
RUN dotnet publish -c Release -o /app/publish

# INSECURE: No HEALTHCHECK defined
# INSECURE: Running as root (no USER instruction)
# INSECURE: Not using multi-stage build - SDK included in production image
ENTRYPOINT ["dotnet", "/app/publish/SensitiveDataApi.dll"]
