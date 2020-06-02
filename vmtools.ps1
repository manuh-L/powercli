import-Module VMware.PowerCLI
 
#Variaveis globais
$vc= (Get-VICredentialStoreItem).Host
$cred= Get-Credential
$conn_vc= Connect-VIServer -Server $vc -Credential $cred
$SnapDate= (Get-Date).ToString("dd/MM/yyyy") -replace '/',''
$ToolsNotInstalled=@{}
 
#Seleciona VMs com guest/OS windows
$VMs=Get-VM * | ? {$_.GuestId -like '*windows*'} | Select Name,PowerState,@{ Name="ToolStatus"; Expression={$_.ExtensionData.Guest.ToolsVersionStatus}},@{N="OSName";Expression= {$_.Guest.OSFullName}}
 
#Verifica se a VM tem o tools instalado e se esta ligada, copia para hashtable
foreach($vm in $VMs){ 
    if($vm.ToolStatus -like "guestToolsNotInstalled" -and $vm.PowerState -like "PoweredOn" )
    {
 
        $ToolsNotInstalled["Nome"]+=@($vm.Name)
        $ToolsNotInstalled["Estado"]+=@($vm.PowerState)
 
    }
}
 
#Cria snapshot na VM
foreach($vm in $ToolsNotInstalled.Nome)
                    {
                         
                      write-host "Efectuando Snapshot na" $vm
                      new-snapshot -vm $vm -name $vm -description "Snap before VMtools Instalation date $SnapDate" -Memory:$false -RunAsync
                         
                         
                    }
 
#Instala VMware Tools
foreach($vm in $ToolsNotInstalled.Nome)
                    {
                          
                      Get-VM $vm | Mount-Tools 
                      write-host "instalando VM tools na"$vm -ForegroundColor Yellow -BackgroundColor Black
                      Invoke-Command -computername $vm -ScriptBlock {Start-Process D:\setup64.exe -ArgumentList '/S /v',"/qn REBOOT=R" -Wait } -Credential $cred
                       
                    }
 
#Apaga snapshots criados
Get-Snapshot $ToolsNotInstalled.Nome | Remove-Snapshot -RunAsync -Confirm:$false
