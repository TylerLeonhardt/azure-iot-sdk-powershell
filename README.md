# Azure IoT SDK PowerShell

An unofficial PowerShell Azure IoT SDK

## Getting Started

To get started, simply import the psd1:

```powershell
Import-Module path/to/AzureIoT.psd1
```

### Connecting to AzureIoT

```powershell
# Configuration
$DeviceConnectionString = ""

# Returns nothing but sets up device client
Connect-AzureIoTDevice -ConnectionString $DeviceConnectionString
```

### Setting up the reported properties (the message configuration, basically) for the device

```powershell
# Set up device configuration for our instance of Azure IoT
# This is a one time step
$reportedPropertiesObj = @{
    MyData = "Hello World"
}
Set-IoTDeviceReportedProperties -ReportedProperties $reportedPropertiesObj
```

### Sending messages to Azure IoT

```powershell
Invoke-IoTDeviceEvent -Message "Hello World"
```

### Listening for direct method invoking

In order to use DirectMethods in the PowerShell SDK, you can define a module with functions that will be run when a Direct Method is received. You'd set the module like so:
```powershell
# pass in module. Module needs to exist in PSModulePath or an absolute path must be supplied
Set-AzureIoTDeviceDirectMethod -Module (Resolve-Path ./ExampleDirectMethodModule.psm1).Path
```

And then in your module define the functions:

```powershell
function Get-AzureIoTManifest {
    return @{
        hello = "Get-HelloWorld"
        echo = "Get-Echo"
    }
}

function Get-HelloWorld ($Request) {
    return @{
        Hello = "World"
    }
}

function Get-Echo ($Request) {
    return @{
        Data = $Request
    }
}

Export-ModuleMember -Function *-*
```

`Get-AzureIoTManifest` must be implemented in your module and it must return a simple hash table in which the key is the method name and the value is the function you wish to run in this module when the method name is invoked.

## Example

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
