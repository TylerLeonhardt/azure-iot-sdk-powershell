using namespace "Microsoft.Azure.Devices.Client"
Get-ChildItem "$PSScriptRoot\lib\core\*.dll" | ForEach-Object { . Import-Module $_.FullName }
Import-Module "$PSScriptRoot\AzureIoT.DirectMethod.Lib\bin\Debug\netstandard2.0\AzureIoT.DirectMethod.Lib.dll"

function Connect-AzureIoTDevice {
    Param(
        [Parameter(Mandatory=$true)]
        [string]
        $ConnectionString,

        [Parameter()]
        [switch]
        $Force
    )

    if ((-not $Script:DEVICE_CLIENT) -or $Force) {
        $Script:DEVICE_CLIENT = [DeviceClient]::CreateFromConnectionString($ConnectionString, [TransportType]::Amqp)
    } else {
        $PSCmdlet.WriteError((
            New-Object -TypeName System.Management.Automation.ErrorRecord -ArgumentList @(
                [System.Exception]'Device Client already connected.'
                $Null
                [System.Management.Automation.ErrorCategory]::ResourceExists
                "DeviceClient")))
    }
    return $Script:DEVICE_CLIENT
}

function Set-AzureIoTDeviceReportedProperties {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [object]$ReportedProperties,

        [Parameter()]
        [object]
        $DeviceClient = $Script:DEVICE_CLIENT,

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
        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            # Variable scope ensures that parent session remains unchanged
            $ConfirmPreference = 'None'
            $reportedPropertiesJson = [Microsoft.Azure.Devices.Shared.TwinCollection]::new(($ReportedProperties | ConvertTo-Json -Depth 100))
            $DeviceClient.UpdateReportedPropertiesAsync($reportedPropertiesJson).Wait()
        }
    }

    End {
    }
}

function Invoke-AzureIoTDeviceEvent {
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Message,

        [Parameter()]
        [object]
        $DeviceClient = $Script:DEVICE_CLIENT,

        [Parameter()]
        [object]
        $Properties
    )
    $messageObj = [Message]::new([System.Text.Encoding]::ASCII.GetBytes($Message));
    foreach($key in $Properties.keys) {
        ([System.Collections.Generic.IDictionary[string, string]]$messageObj.Properties).Add($key, $Properties[$key])
    }
    $DeviceClient.SendEventAsync($messageObj).Wait()
}

function Set-AzureIoTDeviceDirectMethod {
    [CmdletBinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory=$True)]
        [string]
        $Module,

        [Parameter()]
        [object]
        $DeviceClient = $Script:DEVICE_CLIENT,

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
        # -Confirm --> $ConfirmPreference = 'Low'
        # ShouldProcess intercepts WhatIf* --> no need to pass it on
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            Write-Verbose ('[{0}] Reached command' -f $MyInvocation.MyCommand)
            # Variable scope ensures that parent session remains unchanged
            $ConfirmPreference = 'None'
            Import-Module $Module -Force
            $manifest = Get-AzureIoTManifest
            $manifest.Keys | ForEach-Object {
                $del = [AzureIoT.DirectMethod.ScriptBlockDelegate]::Create($Module, $manifest.Item($_))
                $DeviceClient.SetMethodHandlerAsync($_, $del, $null).Wait()
            }
        }
    }

    End {
    }
}

# Export only the functions using PowerShell standard verb-noun naming.
# Be sure to list each exported functions in the FunctionsToExport field of the module manifest file.
# This improves performance of command discovery in PowerShell.
Export-ModuleMember -Function *-*