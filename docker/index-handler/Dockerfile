# escape=`

# FROM sixeyed/msbuild:netfx-4.5.2-webdeploy-10.0.14393.1198 AS builder
FROM dockersamples/modernize-aspnet-builder:10.0.14393.1715 AS builder
ENV NUGET_PATH="C:\Chocolatey\bin" `
    MSBUILD_PATH="C:\Program Files (x86)\MSBuild\14.0\Bin"

RUN $env:PATH = $env:NUGET_PATH + ';' + $env:MSBUILD_PATH + ';' + $env:PATH; `
	[Environment]::SetEnvironmentVariable('PATH', $env:PATH, [EnvironmentVariableTarget]::Machine)

WORKDIR C:\src\SignUp.MessageHandlers.IndexProspect
COPY src\SignUp\SignUp.MessageHandlers.IndexProspect\packages.config .
RUN nuget restore packages.config -PackagesDirectory ..\packages

COPY src\SignUp C:\src
RUN msbuild SignUp.MessageHandlers.IndexProspect.csproj /p:OutputPath=c:\out\index-prospect\IndexProspectHandler

# app image
FROM microsoft/windowsservercore:10.0.14393.1715
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN Set-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters' -Name ServerPriorityTimeLimit -Value 0 -Type DWord

WORKDIR /index-prospect-handler
CMD .\SignUp.MessageHandlers.IndexProspect.exe

ENV MESSAGE_QUEUE_URL="nats://message-queue:4222" `
    ELASTICSEARCH_URL="http://elasticsearch:9200"

COPY --from=builder C:\out\index-prospect\IndexProspectHandler .