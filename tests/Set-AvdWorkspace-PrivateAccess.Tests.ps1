# Dot-source the script (defines Invoke-AvdWorkspacePrivateAccess; does not auto-run)
$script:ScriptPath = Join-Path $PSScriptRoot '..' 'src' 'Set-AvdWorkspace-PrivateAccess.ps1'
if (-not (Test-Path -LiteralPath $script:ScriptPath)) {
    throw "Script not found at '$script:ScriptPath'"
}
. $script:ScriptPath

Describe "Set-AvdWorkspace-PrivateAccess (unit)" {
    BeforeAll {
        # Stubs so Pester can Mock (Pester can only mock existing names)
        function New-AvdWorkspacePrivateEndpoint { throw "stub" }
        function Add-AvdPrivateDnsZoneGroup      { throw "stub" }
        function Disable-AvdWorkspacePublicAccess{ throw "stub" }
        function Enable-AvdWorkspacePublicAccess { throw "stub" }

        # Replace with mocks
        Mock Import-Module                    { }
        Mock New-AvdWorkspacePrivateEndpoint  { @{ Id = '/subs/.../pe/pe-avd' } }
        Mock Add-AvdPrivateDnsZoneGroup       { }
        Mock Disable-AvdWorkspacePublicAccess { }
        Mock Enable-AvdWorkspacePublicAccess  { }
    }

    It "honors -WhatIf on Enable" {
        Invoke-AvdWorkspacePrivateAccess `
            -SubscriptionId '00000000-0000-0000-0000-000000000000' `
            -Mode Enable `
            -WorkspaceResourceId '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.DesktopVirtualization/workspaces/ws' `
            -VNetResourceId '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet1' `
            -SubnetName 'pe' `
            -PrivateDnsZoneResourceIds '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.wvd.microsoft.com' `
            -WhatIf

        Assert-MockCalled New-AvdWorkspacePrivateEndpoint  -Times 0
        Assert-MockCalled Add-AvdPrivateDnsZoneGroup       -Times 0
        Assert-MockCalled Disable-AvdWorkspacePublicAccess -Times 0
        Assert-MockCalled Enable-AvdWorkspacePublicAccess  -Times 0
    }

    It "calls expected functions on Enable" {
        Invoke-AvdWorkspacePrivateAccess `
            -SubscriptionId '00000000-0000-0000-0000-000000000000' `
            -Mode Enable `
            -WorkspaceResourceId '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.DesktopVirtualization/workspaces/ws' `
            -VNetResourceId '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet1' `
            -SubnetName 'pe' `
            -PrivateDnsZoneResourceIds '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.Network/privateDnsZones/privatelink.wvd.microsoft.com' `
            -Confirm:$false

        Assert-MockCalled New-AvdWorkspacePrivateEndpoint  -Times 1
        Assert-MockCalled Add-AvdPrivateDnsZoneGroup       -Times 1
        Assert-MockCalled Disable-AvdWorkspacePublicAccess -Times 1
    }

    It "calls expected functions on Disable" {
        Invoke-AvdWorkspacePrivateAccess `
            -SubscriptionId '00000000-0000-0000-0000-000000000000' `
            -Mode Disable `
            -WorkspaceResourceId '/subscriptions/xxx/resourceGroups/rg/providers/Microsoft.DesktopVirtualization/workspaces/ws' `
            -Confirm:$false

        Assert-MockCalled Enable-AvdWorkspacePublicAccess -Times 1
    }
}
