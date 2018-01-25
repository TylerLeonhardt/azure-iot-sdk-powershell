Import-Module ./AzureIoT.psd1 -Force

# Configuration
$ConnectionString = "<secret>"

# Returns the device client but internally saves the last device client used.
$asdf = Connect-AzureIoTDevice -ConnectionString $ConnectionString

# Set up device configuration for our instance of Azure IoT
# This is a one time step
$reportedPropertiesObj = @{
    SupportedMethods = "test"
    Type = "Mbp"
    Firmware = "1.0"
    Telemetry = @{
        "mbp;v1" = @{
            Interval = "00:00:10"
            MessageTemplate = '{"Temperature":"${temperature}"}'
            MessageSchema = @{
                Name = "mbp;v1"
                Format = "JSON"
                Fields = @{
                    temperature = "Double"
                }
            }
        }
    }
}
Set-IoTDeviceReportedProperties -ReportedProperties $reportedPropertiesObj -DeviceClient $asdf