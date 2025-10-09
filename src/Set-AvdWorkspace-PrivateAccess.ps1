# Set-AvdWorkspace-PrivateAccess.ps1

# 1) Top-level params: NOT mandatory (so dot-sourcing never prompts)
[CmdletBinding(SupportsShouldProcess)]
param(
  [string]$SubscriptionId,
  [ValidateSet('Enable','Disable')][string]$Mode,
  [string]$WorkspaceResourceId,
  [string]$VNetResourceId,
  [string]$SubnetName,
  [string[]]$PrivateDnsZoneResourceIds,
  [hashtable]$Tags
)

# 2) All mandatory enforcement lives in the function
function Invoke-AvdWorkspacePrivateAccess {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][string]$SubscriptionId,
    [Parameter(Mandatory)][ValidateSet('Enable','Disable')][string]$Mode,
    [Parameter(Mandatory)][string]$WorkspaceResourceId,
    [string]$VNetResourceId,
    [string]$SubnetName,
    [string[]]$PrivateDnsZoneResourceIds,
    [hashtable]$Tags
  )

  try { Import-Module AvdPrivateAccess -Force } catch {}

  switch ($Mode) {
    'Enable' {
      if ($PSCmdlet.ShouldProcess($WorkspaceResourceId,'Enable private access')) {
        $pe = New-AvdWorkspacePrivateEndpoint `
          -WorkspaceResourceId $WorkspaceResourceId `
          -VNetResourceId $VNetResourceId `
          -SubnetName $SubnetName `
          -Tags $Tags
        Add-AvdPrivateDnsZoneGroup -PrivateEndpointId $pe.Id -PrivateDnsZoneResourceIds $PrivateDnsZoneResourceIds
        Disable-AvdWorkspacePublicAccess -WorkspaceResourceId $WorkspaceResourceId
      }
    }
    'Disable' {
      if ($PSCmdlet.ShouldProcess($WorkspaceResourceId,'Disable private access')) {
        Enable-AvdWorkspacePublicAccess -WorkspaceResourceId $WorkspaceResourceId
      }
    }
  }
}

# 3) Only auto-run if the script is executed (not dot-sourced in tests)
if ($MyInvocation.InvocationName -ne '.') {
  Invoke-AvdWorkspacePrivateAccess @PSBoundParameters
}
