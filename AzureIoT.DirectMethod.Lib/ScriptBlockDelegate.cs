using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Azure.Devices.Client;

namespace AzureIoT.DirectMethod
{
    public class ScriptBlockDelegate
    {
        public static MethodCallback Create(string module, string functionName)
        {
            return delegate(MethodRequest methodRequest, object userContext) {
                PowerShell powershell = PowerShell
                    .Create()
                    .AddScript(ScriptBlockDelegateHelperScripts.InitializeParameters)
                    .AddParameter("methodRequest", methodRequest)
                    .AddParameter("userContext", userContext)
                    .AddScript(ScriptBlockDelegateHelperScripts.GenerateScript(module, functionName))
                    .AddParameter("methodRequest", methodRequest);

                Collection<Dictionary<string,string>> output = powershell.Invoke<Dictionary<string,string>>();
                powershell.Dispose();

                return Task.FromResult(new MethodResponse(Encoding.UTF8.GetBytes(output[0]["data"]), int.Parse(output[0]["statusCode"])));
            };
        }
    }
}
