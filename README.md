# Vencord CLI Installer Automation Script

## Description

This PowerShell script automates the installation process of Vencord using its Command Line Interface (CLI) tool. It ensures a clean, non-disruptive installation by managing the Discord application state and handling file cleanup.

## Functionality

The script performs the following sequential operations:

- **Closes Discord**: It gracefully terminates the running Discord process if found.
- **Downloads CLI**: It downloads the latest VencordInstallerCli.exe from the official GitHub releases page to a temporary system directory. The download is silent (progress bar suppressed).
- **Executes Installer**: It launches the CLI executable and pauses the script execution (Start-Process -Wait) until the user has completed the installation steps in the newly opened command window.
- **Cleans Up**: The downloaded executable is deleted from the temporary directory.
- **Restarts Discord**: Discord is relaunched using the standard Update.exe launcher path (%LocalAppData%\Discord\Update.exe --processStart Discord.exe) or the one provided as parameter.

## Usage

### Requirements
- PowerShell 5.1 or newer.
- Internet connection.

### Execution
- Save the provided code as a file named Install-Vencord.ps1.
- Open PowerShell.
- Navigate to the directory where you saved the file.

If you encounter an execution error, you may need to adjust your system's execution policy (run PowerShell as Administrator):

```ps1
Set-ExecutionPolicy RemoteSigned -Scope Process
```

Run the script:

```ps1
.\Install-Vencord.ps1
```

### Configuration Variables

The following values are defined as script parameters and can be overridden when executing the script via the command line.

| Parameter         | Description                                                 | Default Value                                                                         | Usage Example                                   |
| ----------------- | ----------------------------------------------------------- | ------------------------------------------------------------------------------------- | ----------------------------------------------- |
| Url               | The URL to download the Vencord CLI installer.              | https://github.com/Vencord/Installer/releases/latest/download/VencordInstallerCli.exe | -Url "https://mycdn.com/installer.exe"          |
| TempInstallerPath | Full path where the file is temporarily saved.              | $env:TEMP\VencordInstallerCli.exe                                                     | -TempInstallerPath "C:\tmp\vencord.exe"         |
| DiscordLauncher   | Path to the Discord updater executable used for restarting. | $env:LocalAppData\Discord\Update.exe                                                  | -DiscordLauncher "C:\Path\To\Canary\Update.exe" |