Import-Module ./AzureIoT.psd1 -Force
# Configuration
$ConnectionString = "<secret>"

# Returns the device client but internally saves the last device client used.
$asdf = Connect-AzureIoTDevice -ConnectionString $ConnectionString

# pass in module. Module needs to exist in PSModulePath or an absolute path must be supplied
Set-AzureIoTDeviceDirectMethod -Module (Resolve-Path ./ExampleDirectMethodModule.psm1).Path