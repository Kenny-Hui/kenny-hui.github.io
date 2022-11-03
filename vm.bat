@echo off
:: BatchGotAdmin
:: https://stackoverflow.com/questions/11525056/how-to-create-a-batch-file-to-run-cmd-as-administrator
::-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/c %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------

GOTO :SETUP
echo Stopping Services...
sc stop SysMain
sc config SysMain start=disabled
sc stop DoSvc
sc config DoSvc start=disabled
GOTO :7ZIP
GOTO :PROCEXP
GOTO :NPP
:: GOTO :VCREDIST
GOTO :CLEANUP
pause

:SETUP
if not exist "./lib" mkdir "lib"
if not exist "./temp" mkdir "temp"

:: Download File VBS
echo set args = WScript.Arguments > lib/download.vbs
echo dim xHttp: Set xHttp = createobject("MSXML2.ServerXMLHTTP") >> lib/download.vbs
echo dim bStrm: Set bStrm = createobject("Adodb.Stream") >> lib/download.vbs
echo xHttp.Open "GET", args(0), False >> lib/download.vbs
echo xHttp.Send >> lib/download.vbs
echo with bStrm >> lib/download.vbs
echo     .type = 1 ' >> lib/download.vbs
echo     .open >> lib/download.vbs
echo     .write xHttp.responseBody >> lib/download.vbs
echo     .savetofile args(1), 2 '//overwrite >> lib/download.vbs
echo end with >> lib/download.vbs

:: Extract ZIP VBS
echo set args = WScript.Arguments > lib/extract.vbs
echo set fso = CreateObject("Scripting.FileSystemObject") >> lib/extract.vbs
echo ZipFile=fso.GetAbsolutePathName(args(0)) >> lib/extract.vbs
echo ExtractTo=fso.GetAbsolutePathName(args(1)) >> lib/extract.vbs
echo If not fso.FolderExists(ExtractTo) Then >> lib/extract.vbs
echo    fso.CreateFolder(ExtractTo) >> lib/extract.vbs
echo End If>> lib/extract.vbs
echo set objShell = CreateObject("Shell.Application") >> lib/extract.vbs
echo set FilesInZip=objShell.NameSpace(ZipFile).items >> lib/extract.vbs
echo objShell.NameSpace(ExtractTo).CopyHere(FilesInZip) >> lib/extract.vbs
echo Set fso = Nothing >> lib/extract.vbs
echo Set objShell = Nothing >> lib/extract.vbs

:: Standalone Downloader
echo @echo off > download.bat
echo set /p dlurl=Enter Download URL: >> download.bat
echo "./lib/download.vbs" %%dlurl%% "./download.zip" >> download.bat

:PROCEXP
echo Downloading Process Explorer...
"./lib/download.vbs" "https://download.sysinternals.com/files/ProcessExplorer.zip" "./temp/procexp.zip"
"./lib/extract.vbs" "./temp/procexp.zip" "procexp"
start "" "./procexp/procexp.exe"

:7ZIP
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=-x64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=-arm64) ELSE set arch=""
echo Downloading 7-zip%arch%...
"./lib/download.vbs" "https://7-zip.org/a/7z2201%arch%.exe" "./temp/7z.exe"
"./temp/7z.exe" /S

:NPP
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=.x64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=.arm64) ELSE set arch=""
echo Downloading Notepad++%arch%...
"./lib/download.vbs" "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.6/npp.8.4.6.Installer%arch%.exe" "./temp/npp.exe"
"./temp/npp.exe" /S

:VCREDIST
::echo Installing vcredist...
::"./lib/download.vbs" "https://aka.ms/vs/17/release/vc_redist.x86.exe" "temp\17_vc_redist_x86.exe"
::"./lib/download.vbs" "https://aka.ms/vs/17/release/vc_redist.x64.exe" "temp\17_vc_redist_x64.exe"
::"./lib/download.vbs" "https://aka.ms/highdpimfc2013x86enu" "temp\13_vc_redist_x86.exe"
::"./lib/download.vbs" "https://aka.ms/highdpimfc2013x64enu" "temp\13_vc_redist_x64.exe"
::"./lib/download.vbs" "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" "temp\12_vc_redist_x86.exe"
::"./lib/download.vbs" "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" "temp\12_vc_redist_x64.exe"
::"./lib/download.vbs" "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe" "temp\10_vc_redist_x86.exe"
::"./lib/download.vbs" "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "temp\10_vc_redist_x64.exe"
::"./lib/download.vbs" "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe" "temp\08_vc_redist_x86.exe"
::"./lib/download.vbs" "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" "temp\08_vc_redist_x64.exe"
::
::temp\17_vc_redist_x86.exe /q /norestart
::temp\17_vc_redist_x64.exe /q /norestart
::temp\13_vc_redist_x86.exe /q /norestart
::temp\13_vc_redist_x64.exe /q /norestart
::temp\10_vc_redist_x86.exe /q /norestart
::temp\10_vc_redist_x64.exe /q /norestart
::temp\08_vc_redist_x86.exe /q /norestart
::temp\08_vc_redist_x64.exe /q /norestart
::
:CLEANUP
rd temp /s/q
pause