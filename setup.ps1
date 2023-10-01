param(
    [Parameter(HelpMessage="Skip app installation")]
    [switch]$SkipAppInstall = $False
)

# List of Winget Package ID's to be installed by default
$apps = @(
    'AgileBits.1Password'
    'git.git'
    'Google.Chrome'
    'Kubernetes.Kubectl'
    'Microsoft.Powershell'
    'Microsoft.PowerToys'
    'Microsoft.VisualStudioCode'
    'Microsoft.WindowsTerminal'
    'OpenVPNTechnologies.OpenVPN'
    'Telegram.TelegramDesktop'
    'WireGuard.WireGuard'
)
# List of VSCode Extension ID's to be installed by default
$vscodeExtensions = @(
    'ms-vscode-remote.remote-wsl'
    'ms-vscode-remote.remote-ssh'
    'ms-vscode-remote.vscode-remote-extensionpack'
)
function Install-Apps {
    param (
        $Apps
    )
    foreach ($app in $Apps) {
        winget install --silent --accept-package-agreements --accept-source-agreements $app
    }  
}

function Install-VSCode-Extensions {
    param (
        $Extensions
    )
    foreach ($Extension in $Extensions) {
        code --install-extension $Extension
    }  
}

function Set-WindowsTerminal-As-Default-Console {
    # GUID's are taken after using the graphical config method
    $registryPathToDefaultConsoleSetting = "HKCU:\Console\%%Startup"
    $delegationConsoleGuid = "{2EACA947-7F5F-4CFA-BA87-8F7FBEEFBE69}"
    $delegationTerminalGuid = "{E12CFF52-A866-4C77-9A90-F570A7AA2C6B}"

    if (!(Test-Path -Path $registryPathToDefaultConsoleSetting)) {
        New-Item -Path HKCU:\Console\%%Startup
    }

    Set-ItemProperty -Path $registryPathToDefaultConsoleSetting -Name "DelegationConsole" -Type String -Value $delegationConsoleGuid
    Set-ItemProperty -Path $registryPathToDefaultConsoleSetting -Name "DelegationTerminal" -Type String -Value $delegationTerminalGuid
}

function Install-WSL {
    Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux"
    # We use ubuntu here because it has the best out of the box experience with WSL.
    wsl --install ubuntu -n
    wsl --set-default-version 2
}

if (!$SkipAppInstall) {
    Install-Apps $apps    
}

# Run the functions
Set-WindowsTerminal-As-Default-Console
Install-WSL
Install-VSCode-Extensions $vscodeExtensions


$FinishMessage = @"
The installation is done, you need to restart your machine to
apply all changes to enviornment variables and the registry.
"@

Write-Host $FinishMessage