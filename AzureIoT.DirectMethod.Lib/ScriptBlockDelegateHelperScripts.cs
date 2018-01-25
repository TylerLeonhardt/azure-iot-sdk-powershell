namespace AzureIoT.DirectMethod
{
    public class ScriptBlockDelegateHelperScripts
    {
        public static string InitializeParameters => @"
            param($methodRequest, $userContext)
            $global:methodRequest = $methodRequest
            $global:userContext = $userContext";

        public static string GenerateScript(string module, string functionName){
            var script = $"param($methodRequest); Import-Module {module}; $data = {functionName} -Request ($methodRequest.DataAsJson | ConvertFrom-Json);";
            return script + @"
                $dict = New-Object 'system.collections.generic.dictionary[[string],[string]]'
                if ($data.GetType().Name -eq 'Hashtable') {
                    if ($data.statusCode) {
                        if ($data.GetType().Name -eq 'Hashtable') {
                            $dict.Add('data', ($data.data | ConvertTo-Json))
                        } else {
                            $obj = @{
                                data = $data.data
                            }
                            $dict.Add('data', ($obj | ConvertTo-Json))
                        }
                        $dict.Add('statusCode', '' + $data.statusCode)
                    } else {
                        $dict.Add('data', ($data | ConvertTo-Json))
                        $dict.Add('statusCode', '200')
                    }
                } else {
                    $obj = @{
                        data = $data
                    }
                    $dict.Add('data', ($obj | ConvertTo-Json))
                    $dict.Add('statusCode', '200')
                }
                Get-Variable -Include methodRequest,userContext -Scope Global | Remove-Variable -Force
                return $dict";
        }
    }
}