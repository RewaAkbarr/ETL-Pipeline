# Gunakan image resmi dari Microsoft
FROM mcr.microsoft.com/mssql/server:2019-latest

# Atur variabel lingkungan
ENV ACCEPT_EULA=Y
ENV SA_PASSWORD=YourStrong!Passw0rd

# Expose port SQL Server
EXPOSE 1433