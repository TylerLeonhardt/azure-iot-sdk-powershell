using namespace "Microsoft.Azure.Devices.Client"
Get-ChildItem "$PSScriptRoot\lib\core\*.dll" | ForEach-Object { . Import-Module $_.FullName }

function Connect-IoTDevice {
    Param(
        [Parameter(Mandatory=$true)]
        [string]
        $IoTHubUri,
        [Parameter(Mandatory=$true)]
        [string]
        $deviceKey,
        [Parameter(Mandatory=$true)]
        [string]
        $deviceId
    )
    $auth = [DeviceAuthenticationWithRegistrySymmetricKey]::new("pi", $deviceKey)
    $Script:DEVICE_CLIENT = [DeviceClient]::Create($iotHubUri, $auth, [TransportType]::Mqtt)
}

function Set-IoTDeviceReportedProperties {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [object]$ReportedProperties,

        [Parameter()]
        [switch]
        $Force
    )

    Begin {
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }

    Process {
        <# Pre-impact code #>

        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            # Variable scope ensures that parent session remains unchanged
            $ConfirmPreference = 'None'
            $reportedPropertiesJson = [Microsoft.Azure.Devices.Shared.TwinCollection]::new(($ReportedProperties | ConvertTo-Json))
            $DEVICE_CLIENT.UpdateReportedPropertiesAsync($reportedPropertiesJson).GetAwaiter().GetResult()
        }

        <# Post-impact code #>
    }

    End {
    }
}

function Invoke-IoTDeviceEvent {
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Message,
        [Parameter()]
        [object]
        $Properties
    )
    $messageObj = [Message]::new([System.Text.Encoding]::ASCII.GetBytes($Message));
    foreach($key in $Properties.keys) {
        ([System.Collections.Generic.IDictionary[string, string]]$messageObj.Properties).Add($key, $Properties[$key])
    }
    $DEVICE_CLIENT.SendEventAsync($messageObj).Wait()
    Write-Verbose "SENT EVENT"
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*