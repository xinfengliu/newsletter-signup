# escape=`
FROM microsoft/mssql-server-windows-express:2017-windowsservercore-10.0.14393.1715
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV ACCEPT_EULA="Y" `
    PASSWORD_PATH="_" `
    sa_password="_" `
    DATA_PATH="C:\data" 


VOLUME ${DATA_PATH}

WORKDIR C:\init
COPY init.ps1 .

CMD ["powershell", "./init.ps1", `
    "-sa_password $env:sa_password", `
    "-db_name $env:db_name", `
    "-data_path $env:data_path", `
    "-secret_path $env:password_path", `
    "-Verbose"]
# below not working, reporting error: "init.sp1" not found.
# CMD ./init.sp1 `
#     -sa_password $env:sa_password `
#     -data_path $env:data_path `
#     -secret_path $env:password_path `
#     -db_name $env:db_name `
#     -Verbose