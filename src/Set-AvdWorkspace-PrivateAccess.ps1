# Script is testable: wrap logic in a function; only auto-run when executed.
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

function Invoke-AvdWorkspacePrivateAccess {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$SubscriptionId,
        [Parameter(Mandatory)][ValidateSet('Enable','Disable')][string]$Mode,
        [Parameter(Mandatory)][string]$WorkspaceResourceId,
        [string]$VNetResourceId,[string]$SubnetName,[string[]]$PrivateDnsZoneResourceIds,[hashtable]$Tags
    )

    # Import module (CI’s unit tests will Mock this)
    try { Import-Module AvdPrivateAccess -Force } catch {}

    # No Azure calls in unit tests—assume subscription already selected
    switch ($Mode) {
        'Enable' {
            if ($PSCmdlet.ShouldProcess($WorkspaceResourceId,'Enable private access')) {
                $pe = New-AvdWorkspacePrivateEndpoint -WorkspaceResourceId $WorkspaceResourceId -VNetResourceId $VNetResourceId -SubnetName $SubnetName -Tags $Tags
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

if ($MyInvocation.InvocationName -ne '.') {
    Invoke-AvdWorkspacePrivateAccess @PSBoundParameters
}
