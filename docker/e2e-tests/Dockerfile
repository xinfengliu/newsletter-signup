# escape=`

# FROM sixeyed/msbuild:netfx-4.5.2-webdeploy-10.0.14393.1198 AS builder
FROM dockersamples/modernize-aspnet-builder:10.0.14393.1715 AS builder
ENV NUGET_PATH="C:\Chocolatey\bin" `
    MSBUILD_PATH="C:\Program Files (x86)\MSBuild\14.0\Bin"

RUN $env:PATH = $env:NUGET_PATH + ';' + $env:MSBUILD_PATH + ';' + $env:PATH; `
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

WORKDIR C:\src\SignUp.EndToEndTests
COPY src\SignUp\SignUp.EndToEndTests\packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY src\SignUp C:\src
RUN msbuild SignUp.EndToEndTests.csproj /p:OutputPath=C:\out\tests\EndToEndTests

# test runner
FROM sixeyed/nunit:3.6.1-10.0.14393.1198
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord

WORKDIR /e2e-tests
CMD nunit3-console SignUp.EndToEndTests.dll

ENV DB_CONNECTION_STRING_PATH="C:\ProgramData\Docker\secrets\signup-db.connectionstring"

COPY --from=builder C:\out\tests\EndToEndTests .