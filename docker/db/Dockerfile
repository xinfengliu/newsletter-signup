# escape=`
FROM microsoft/mssql-server-windows-express:2017-windowsservercore-10.0.14393.1715

ENV ACCEPT_EULA="Y" `
    PASSWORD_PATH="C:\ProgramData\Docker\secrets\signup-db-sa.password"

COPY init.ps1 .

CMD ["powershell", "./init.ps1", "-Verbose"]