$logPath = "C:\opt\logs\"
$scriptName = $MyInvocation.MyCommand.Name
$logFile = $scriptName + "." + (Get-Date -format FileDateTimeUniversal)
$transcriptFile = $logPath + $logFile + ".log"
Start-Transcript -Path $transcriptFile

# Force TLS12
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

function Verify-Path ($exeName, $exePath) {
    # Verify exeName is in the path
    If ((Get-Command "$exeName" -ErrorAction SilentlyContinue) -eq $null) 
    {
        Write-Host "$exeName not found in path -- adding $exePath"
        $env:PATH += ";$exePath"
        
        If ((Get-Command "$exeName" -ErrorAction SilentlyContinue) -eq $null) 
        {
            Write-Host "$exeName still not found in path -- refreshing environment variables"
            refreshenv

            If ((Get-Command "$exeName" -ErrorAction SilentlyContinue) -eq $null) 
            {
                Write-Host "$exeName STILL not found in path ???"
            }    
        }
    }
}

function Install-Chocolatey {
    Write-Output "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    
    # Globally Auto confirm every action
    choco feature enable -n allowGlobalConfirmation

    Write-Output "Installing Chocolatey - COMPLETE"
  }

function Install-ChocolateyPackage ($packageName) {
    Write-Output "Installing Chocolatey package $packageName"
    $ignoreReboot = $true

    try {
        choco install $packageName --yes --no-progress --failonstderr
    }
    catch {
        Write-Warning "An exception occurred while trying to execute chocolatey command."
    }
    
    If ($LASTEXITCODE -eq 3010 -and $ignoreReboot -eq $True)
    {
		Write-Warning "$packageName installation has requested a reboot. Supressing this because ignoreReboot is set to True (default: True)."
    }
}

function Install-Utilities {
    Write-Output "Installing helpful tools and utilities..."
    Install-ChocolateyPackage awscli
    Install-ChocolateyPackage sublimetext3
    Install-ChocolateyPackage notepadplusplus.install
    Install-ChocolateyPackage googlechrome
    Install-ChocolateyPackage jq
    Install-ChocolateyPackage git
    Install-ChocolateyPackage ag
    Install-ChocolateyPackage wget
    Install-ChocolateyPackage baretail
    Install-ChocolateyPackage baregrep
    Install-ChocolateyPackage sysinternals
    Install-ChocolateyPackage 7zip
    #Install-ChocolateyPackage windbg
    Install-ChocolateyPackage heavyload   ## HeavyLoad.exe /CPU 2 /MEMORY 200 /FILE 150 /TESTFILEPATH "D:\Users\exampleuser\AppData\Local\Temp\Test1" /GPU /TREESIZE /DURATION 10 /AUTOEXIT /START
    Install-ChocolateyPackage lazydocker
    Install-ChocolateyPackage treesizefree
    Install-ChocolateyPackage nssm # Vault still doesn't understand how to run as a service
    Install-ChocolateyPackage beyondcompare
}

function Install-VSCode {
    Write-Output "Installing Visual Studio Code..."
    Install-ChocolateyPackage vscode

    Verify-Path -exeName "code" -exePath "C:\Program Files\Microsoft VS Code\bin"

    code --install-extension ms-vscode.powershell
    code --install-extension hashicorp.terraform
    code --install-extension a-bentofreire.vsctoix
    code --install-extension ibm.output-colorizer
    code --install-extension eamodio.gitlens
    code --install-extension alefragnani.bookmarks
    code --install-extension gruntfuggly.todo-tree

    # Upgrade PowerShell for vscode debugging
    Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber
} 

function Install-Golang {
    Write-Output "Installing base golang package"
    # Install golang
    Install-ChocolateyPackage golang
}

function Install-Golang-Debug {
    Write-Output "Installing Golang VSCode extension and debug modules..."

    # Install VSCode extension
    code --install-extension golang.go
    
    Verify-Path -exeName "go" -exePath "C:\Go\bin"
    Verify-Path -exeName "git" -exePath "C:\Program Files\Git\cmd"

    # Install Go modules
    go get -v github.com/ramya-rao-a/go-outline
    go get -v github.com/sqs/goreturns
    go get -v github.com/go-delve/delve/cmd/dlv
    go get -v github.com/mdempsky/gocode
    go get -v github.com/uudashr/gopkgs/v2/cmd/gopkgs
    go get -v github.com/rogpeppe/godef
    go get -v golang.org/x/tools/cmd/goimports
    go get -v golang.org/x/tools/cmd/guru

    # Really helpful for debugging go-sockaddr templates
    go get -u github.com/hashicorp/go-sockaddr/cmd/sockaddr

    # pprof tool requires graphviz to generate GIF's
    Install-ChocolateyPackage graphviz
}

function Install-Python {
    Write-Output "Installing Python and modules..."
    Install-ChocolateyPackage python

    # TODO - make sure it's in !!!ALL-THE-PATHS!!!
    $env:PATH += ";C:\Python38\Scripts"

    #  Python is weird -- use the py launcher, which isn't on the path, but is found in C:\Windows\py.exe
    #Verify-Path "python", "C:\Python38"
    
    # Upgrade pip
    py -m pip install --upgrade pip

    # Install httpserver for the Nomad Python task driver plugin
    pip install httpserver

    # Install httpie for usability and feature parity with Linux
    pip install --upgrade pip setuptools pip install --upgrade httpie
}


function Install-Hey {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

    # Hide progress bar to keep logs clean
    $progresspreference = 'silentlyContinue'
    Invoke-WebRequest `
        -Uri https://storage.googleapis.com/hey-release/hey_windows_amd64 `
        -OutFile C:\opt\hey.exe
    $progresspreference = 'Continue'
}

function Install-OhMyPosh {
    Install-Module posh-git -Scope CurrentUser
    Install-Module oh-my-posh -Scope CurrentUser
}

function Refresh-Help {
    Write-Output "Updating PowerShell help files..."
    # FYI - Some help will fail to update because of stale Microsoft links
    Update-Help -Force -ErrorAction SilentlyContinue
    Write-Output "Updating PowerShell help files - COMPLETE"
}

Install-Chocolatey
Install-Utilities
Install-VSCode
Install-Golang
Install-Golang-Debug
Install-Python
Install-Hey
Update-Help

# Some versions of .NET require a reboot. Handling this within Packer, but the
# exit code needs to be re-directed to keep the provisioning step from failing.
If ($LASTEXITCODE -eq 3010)
{
  Exit 0
}