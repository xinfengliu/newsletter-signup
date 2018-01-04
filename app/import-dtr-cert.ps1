param([string]$DTR_ADDR)

# Thanks to https://stackoverflow.com/a/46254549 
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

Write-Host "`nDownloading DTR self-signed CA certificate from https://$DTR_ADDR/ca..."
Invoke-WebRequest -debug -verbose -uri "https://$DTR_ADDR/ca" -o c:\ca.crt
Write-Host "done.`n"

Write-Host "Adding DTR self-signed CA certificate to the system's trust store..."
Import-Certificate c:\ca.crt -CertStoreLocation Cert:\LocalMachine\AuthRoot
Del c:\ca.crt
Write-Host "done.`n"

