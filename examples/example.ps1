Import-Module ./AzureIoT.psd1 -Force

# Configuration
$iotHubUri = "<YOUR VALUE HERE>.azure-devices.net"
$deviceKey = "<YOUR VALUE HERE>"

# Returns nothing but sets up device client
Connect-IoTDevice -IoTHubUri $iotHubUri -deviceKey $deviceKey -deviceId "pi"

# Set up device configuration for our instance of Azure IoT
# This is a one time step
$reportedPropertiesObj = @{
    Type = "Pi"
    Firmware = "1.0"
    Telemetry = @{
        "pi;v1" = @{
            Interval = "00:00:10"
            MessageTemplate = '{"Temperature":"${temperature}"}'
            MessageSchema = @{
                Name = "pi;v1"
                Format = "JSON"
                Fields = @{
                    temperature = "Double"
                }
            }
        }
    }
}
Set-IoTDeviceReportedProperties -ReportedProperties $reportedPropertiesObj

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
    Invoke-IoTDeviceEvent -Message ($telemetryDataPoint | ConvertTo-Json) -Properties $properties
    Start-Sleep -s 5
}