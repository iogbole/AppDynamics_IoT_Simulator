$Params = @{
    Method = 'Post'
    URI = 'http://ec2-34-221-208-91.us-west-2.compute.amazonaws.com:7001/eumcollector/iot/v1/application/EUM-AAB-AUA/beacons'
    Headers = @{'accept'='application/json'}
}

$body = Get-Content ./testBeacon.json -Raw

Invoke-RestMethod -v @Params -Body $body -SkipCertificateCheck -StatusCodeVariable resp

Write-Host "ResponseCode =  " $resp

