Import-Module ./AzureIoT.psd1 -Force

# Configuration
$ConnectionString = "<secret>"

# Returns the device client but internally saves the last device client used.
$asdf = Connect-AzureIoTDevice -ConnectionString $ConnectionString

# Sending data loop
# random data for now
$minTemperature = 20
$rand = [Random]::new()
while ($true) {
    # Random data
    $currentTemperature = $minTemperature + $rand.NextDouble() * 15

    $telemetryDataPoint = @{
        Temperature = $currentTemperature
    };

    $properties = @{
        '$$CreationTimeUtc' = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
        '$$MessageSchema' = 'Pi;v1'
        '$$ContentType' = 'JSON'
    }
    Invoke-AzureIoTDeviceEvent -Message ($telemetryDataPoint | ConvertTo-Json) -Properties $properties
    Start-Sleep -s 5
}