# Azure IoT SDK PowerShell

An unofficial PowerShell Azure IoT SDK

## Getting Started

To get started, simply import the psd1:

```powershell
Import-Module path/to/AzureIoT.psd1
```

Connecting to AzureIoT:

```powershell
# Configuration
$iotHubUri = "<YOUR VALUE HERE>.azure-devices.net"
$deviceKey = "<YOUR VALUE HERE>"

# Returns nothing but sets up device client
Connect-IoTDevice -IoTHubUri $iotHubUri -deviceKey $deviceKey -deviceId "pi"
```

Setting up the reported properties (the message configuration, basically) for the device:

```powershell
# Set up device configuration for our instance of Azure IoT
# This is a one time step
$reportedPropertiesObj = @{
    MyData = "Hello World"
}
Set-IoTDeviceReportedProperties -ReportedProperties $reportedPropertiesObj
```

Sending messages to Azure IoT:

```powershell
Invoke-IoTDeviceEvent -Message "Hello World"
```

Another example more so in the style of interacting with [Azure IoT Suite](https://azure.microsoft.com/en-us/suites/iot-suite/):

Configuration:
```powershell
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
```

Sending Events:
```powershell
$telemetryDataPoint = @{
    Temperature = 50 # hard coded :)
};

# Properties preconfigured in Azure IoT Suite
$properties = @{
    '$$CreationTimeUtc' = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ")
    '$$MessageSchema' = 'Pi;v1'
    '$$ContentType' = 'JSON'
}
Invoke-IoTDeviceEvent -Message ($telemetryDataPoint | ConvertTo-Json) -Properties $properties
```