function Get-AzureIoTManifest {
    return @{
        hello = "Get-HelloWorld"
        echo = "Get-Echo"
        test = "Get-Test"
        error = "Get-Error"
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

function Get-Test ($Request) {
    return "test"
}

function Get-Error ($Request) {
    return @{
        statusCode = 500
        data = @{ rip = $true }
    }
}

Export-ModuleMember -Function *-*