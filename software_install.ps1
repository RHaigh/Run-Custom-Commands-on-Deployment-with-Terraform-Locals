# SQL Server install
# The write host commands will output to our log file, along with any error messages. This will help us pinpoint any failures and is good practise 
Write_host "Downloading SQL Server 2019..."
$Path = $env:TEMP
$Installer = "SQL2019-SSEI-Expr.exe"
$URL = "https://go.microssoft.com/fwlink/?linkid=866658"
Invoke-WebRequesst $URL -OutFile $Path/$Installer

# Here we instruct powershell to accept license terms and conditions and install without a prompt. It will then wait until install is complete before proceeding
Write-Host "Installing SQL Server..."
Start-Process -FilePath $Path/$Installer -Args "/ACTION=INSTALL /IACCEPTSQLSERVERLICENSETERMS /QUIET" -Verb RunAs -Wait
Remove-Item $Path/$Installer

# Python 3 install and PATH 
# Define the download URL and installation path
$PythonDownloadUrl = "https://www.python.org/ftp/python/3.9.7/python-3.9.7-amd64.exe"
$PythonInstaller = "$env:TEMP\\python-installer.exe"

Write-Host "Downloading Python installer..."
# Download Python installer
Invoke-WebRequest -Uri $PythonDownloadUrl -OutFile $PythonInstaller

Write-Host "Installing Python..."
# Install Python with default settings and add it to the PATH
Start-Process -FilePath $PythonInstaller -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait

Write-Host "Removing the installer..."
# Remove the installer
Remove-Item $PythonInstaller

Write-Host "Adding Python to the System PATH..."
# Add Python to the System PATH
$PythonPath = (Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment").GetValue("PATH")
$PythonInstallPath = "$env:ProgramFiles\Python39"
if (-not $PythonPath.Contains($PythonInstallPath)) {
  $NewPythonPath = $PythonPath + ";" + $PythonInstallPath + ";" + $PythonInstallPath + "\Scripts"
  [Environment]::SetEnvironmentVariable("PATH", $NewPythonPath, [System.EnvironmentVariableTarget]::Machine)
}
Write-Host "Python installation completed."

# Pip Install common libraries
Pip install pandas
pip install matlab
