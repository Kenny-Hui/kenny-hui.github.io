@echo off
setlocal enableextensions enabledelayedexpansion
:: BatchGotAdmin
:: https://stackoverflow.com/questions/11525056/how-to-create-a-batch-file-to-run-cmd-as-administrator
::-------------------------------------
:: Check for permissions
net session >nul 2>&1
:: If error flag set, we do not have admin.
if not '%errorlevel%' == '0' (
    goto UACPrompt
) else (
	goto gotAdmin
)

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params = %*:"="
    echo UAC.ShellExecute "cmd.exe", "/k %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"
::--------------------------------------
title VMSetup
VER | FINDSTR /L "5.1." > NUL
IF %ERRORLEVEL% EQU 0 set isWinXP=true

set ver7z=2201
set verFF=106.0
set verNpp=8.4.6
set verMpt=0.64.0
set verKm=76.4.6
set dateKm=20221029

if "%isWinXP%" == "true" (
	set verNpp=7.9.2
	set verFF=52.0esr
)

call :SETUP
GOTO :MENU
pause

:SETUP
if not exist "%temp%\vmsetup" (
	mkdir "%temp%\vmsetup"
)

if not exist "%temp%\vmsetup\temp" (
	mkdir "%temp%\vmsetup\temp"
)

:: Download File VBS
(
	echo On Error Resume Next
	echo set args = WScript.Arguments
	echo dim xHttp: Set xHttp = createobject^("MSXML2.XMLHTTP.6.0"^)
	echo dim bStrm: Set bStrm = createobject^("Adodb.Stream"^)
	echo url=args^(0^)
	echo destination=args^(1^)
	echo xHttp.Open "GET", url, False
	echo xHttp.Send
	echo if Err.Number ^<^> 0 Then
	echo 	WScript.Quit^(1^)
	echo end if
	echo with bStrm
	echo     .type = 1
	echo     .open
	echo     .write xHttp.responseBody
	echo     .savetofile destination, 2
	echo     .Close
	echo end with
) > "%temp%\vmsetup\download.vbs"

:: Download wget
if not exist "%temp%\vmsetup\wget.exe" (
	"%temp%\vmsetup\download.vbs" "https://eternallybored.org/misc/wget/1.21.3/64/wget.exe" "%temp%\vmsetup\wget.exe"
)

:: Extract ZIP VBS
echo set args = WScript.Arguments > %temp%\vmsetup\extract.vbs
echo set fso = CreateObject("Scripting.FileSystemObject") >> %temp%\vmsetup\extract.vbs
echo ZipFile=fso.GetAbsolutePathName(args(0)) >> %temp%\vmsetup\extract.vbs
echo ExtractTo=fso.GetAbsolutePathName(args(1)) >> %temp%\vmsetup\extract.vbs
echo If not fso.FolderExists(ExtractTo) Then >> %temp%\vmsetup\extract.vbs
echo    fso.CreateFolder(ExtractTo) >> %temp%\vmsetup\extract.vbs
echo End If>> %temp%\vmsetup\extract.vbs
echo set objShell = CreateObject("Shell.Application") >> %temp%\vmsetup\extract.vbs
echo set FilesInZip=objShell.NameSpace(ZipFile).items >> %temp%\vmsetup\extract.vbs
echo objShell.NameSpace(ExtractTo).CopyHere(FilesInZip) >> %temp%\vmsetup\extract.vbs
echo Set fso = Nothing >> %temp%\vmsetup\extract.vbs
echo Set objShell = Nothing >> %temp%\vmsetup\extract.vbs

:MENU
cls
echo Please select...
echo [0] Exit
echo [1] Install OpenBVE Nightly with Animated Demonstration Route
echo [2] Install Mozilla Firefox %verFF%
echo [3] Install Google Chrome
echo [4] Install K-Meleon
echo [5] Install Microsoft Edge
echo ==============================
echo [10] Install 7-zip
echo [11] Install Microsoft PowerToys (x64/arm64, %verMpt%)
echo [12] Install Notepad++ %verNpp%
echo [13] Install Process Explorer
echo ==============================
echo [20] Disable Superfetch (SysMain)
echo [21] Disable Delivery Optimization (DoSys)
echo [22] Reset hosts file
echo [23] Enable built-in Administrator Account
echo [24] Disable built-in Administrator Account
echo [25] Configure Windows 10 Taskbar Search
echo ==============================
echo [30] Install Microsoft Visual C++ redistributable (2008-latest)
echo [31] Install Adoptium JDK
echo [32] Install .NET Framework

set /p choice=Choice: 
if "%choice%" == "0" (CALL :EXIT)
if "%choice%" == "1" (CALL :OB)
if "%choice%" == "2" (CALL :FF)
if "%choice%" == "3" (CALL :GC)
if "%choice%" == "4" (CALL :KM)
if "%choice%" == "5" (CALL :MSE)
if "%choice%" == "10" (CALL :7ZIP)
if "%choice%" == "11" (CALL :MPT)
if "%choice%" == "12" (CALL :NPP)
if "%choice%" == "13" (CALL :PROCEXP)
if "%choice%" == "20" (CALL :DSM)
if "%choice%" == "21" (CALL :DDO)
if "%choice%" == "22" (CALL :RHF)
if "%choice%" == "23" (CALL :EADMIN)
if "%choice%" == "24" (CALL :DADMIN)
if "%choice%" == "25" (CALL :W10SEARCHBOX)
if "%choice%" == "30" (CALL :VCREDIST)
if "%choice%" == "31" (CALL :AJDK)
if "%choice%" == "32" (CALL :NETFRAMEWORK)

GOTO :MENU

:OB
cls
if not exist "C:\Program Files\7-Zip" (
	echo 7-zip is required for this task to complete. Please install 7-zip.
	pause
	CALL :FINISHTASK ", please install 7-zip."
)
echo Downloading OpenBVE Nightly...
call :DOWNLOAD "https://openbve-project.net/version.xml" "%temp%\vmsetup\temp\obVer.xml"
for /f %%i in ('findstr "<version>" %temp%\vmsetup\temp\obVer.xml') do (set res=%%i)
set obVer=%res:~9,7%
cls
echo Latest OpenBVE version is %obVer%
call :DOWNLOAD "https://github.com/leezer3/OpenBVE/releases/download/%obVer%/OpenBVE-%obVer%.zip" "%temp%\vmsetup\temp\ob.zip"
"%temp%\vmsetup\extract.vbs" "%temp%\vmsetup\temp\ob.zip" "%userprofile%\Downloads\OpenBVE"
echo Downloading Animated Demo Route...
call :DOWNLOAD "https://openbve-project.net/files/DemoRoute1.zip" "%temp%\vmsetup\temp\adm.zip"
:: Forced to use 7-zip, OpenBVE Package is compressed in a weird way Windows can't read.
"C:\Program Files\7-Zip\7z.exe" e "%temp%\vmsetup\temp\adm.zip" -o "%userprofile%\Downloads\AnimDemoRoute"
start "" "%userprofile%\Downloads\OpenBVE\RouteViewer.exe" "%userprofile%\Downloads\AnimDemoRoute\Route\Animated Object Demonstration Route.csv"
CALL :CLEANUP
CALL :FINISHTASK "installing OpenBVE Nightly with Animated Demonstration Route"

:FF
cls
echo Installing Firefox %verFF%...
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=64-aarch64) ELSE set arch=32
call :DOWNLOAD "https://ftp.mozilla.org/pub/firefox/releases/%verFF%/win%arch%/en-US/Firefox Setup %verFF%.exe" "%temp%\vmsetup\temp\ff.exe"
"%temp%\vmsetup\temp\ff.exe" /S /PreventRebootRequired=true /MaintenanceService=false
CALL :CLEANUP
CALL :FINISHTASK "installing Firefox %verFF%"

:GC
cls
echo Installing Google Chrome...
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=64) ELSE set arch=""
call :DOWNLOAD "https://dl.google.com/chrome/install/googlechromestandaloneenterprise%arch%.msi" "%temp%\vmsetup\temp\gc.msi"
msiexec /i "%temp%\vmsetup\temp\gc.msi" /qn /norestart
CALL :CLEANUP
CALL :FINISHTASK "installing Google Chrome"

:KM
cls
if not exist "C:\Program Files\7-Zip" (
	echo 7-zip is required for this task to complete. Please install 7-zip.
	pause
	CALL :FINISHTASK ". Please install 7-zip"
)
echo Installing K-Meleon %verKm% %dateKm%...
call :DOWNLOAD "https://o.rthost.win/kmeleon/KM%verKm%-Goanna-%dateKm%.7z" "%temp%\vmsetup\temp\km.7z"
"C:\Program Files\7-Zip\7z.exe" e "%temp%\vmsetup\temp\km.7z" -o"%appdata%\KM-Goanna" -y
start "" "%appdata%\KM-Goanna\k-meleon.exe"
CALL :CLEANUP
CALL :FINISHTASK "installing K-Meleon %verKm%"

:MSE
cls
echo Please select channel.
echo [0] Back to menu
echo [1] Stable
echo [2] Beta
echo [3] Dev
echo [4] Canary
set /p verNum=Please select: 
if "%verNum%" == "0" ( GOTO :MENU )
if "%verNum%" == "1" (
	set mesBranch=Stable
) else (
	if "%verNum%" == "2" (
		set mesBranch=Beta
	) else (
		if "%verNum%" == "3" (
			set mesBranch=Dev
		) else (
			if "%verNum%" == "4" (
				set mesBranch=Canary
			) else (
				GOTO :MES
			)
		)
	)
)

echo Installing Microsoft Edge (%ver%)...
call :DOWNLOAD "https://go.microsoft.com/fwlink/?linkid=2109047&Channel=%mesBranch%&language=en&consent=1" "%temp%\vmsetup\temp\mes.exe"
"%temp%\vmsetup\temp\mes.exe" /silent /install
CALL :CLEANUP
CALL :FINISHTASK "installing Microsoft Edge (%mesBranch%)"

:7ZIP
cls
echo "Installing 7-zip..."
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=-x64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=-arm64) ELSE set arch=""
call :DOWNLOAD "https://7-zip.org/a/7z%ver7z%%arch%.exe" "%temp%\vmsetup\temp\7z.exe"
"%temp%\vmsetup\temp\7z.exe" /S
CALL :CLEANUP
CALL :FINISHTASK "installing 7-zip (%ver%)"

:MPT
cls
echo Installing Microsoft PowerToys...
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=x64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=arm64) ELSE set arch=32
if arch==32 (
	echo No 32-bit build available for Microsoft Powertoys.
	pause
	CALL :FINISHTASK "."
)

call :DOWNLOAD "https://github.com/microsoft/PowerToys/releases/download/v%verMpt%/PowerToysSetup-%verMpt%-%arch%.exe" "%temp%\vmsetup\temp\mpt.exe"
"%temp%\vmsetup\temp\mpt.exe" /install /quiet /norestart
CALL :CLEANUP
CALL :FINISHTASK "installing Microsoft PowerToys"

:NPP
cls
echo Downloading Notepad++...
If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=.x64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=.arm64) ELSE set arch=""
call :DOWNLOAD "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v%verNpp%/npp.%verNpp%.Installer%arch%.exe" "%temp%\vmsetup\temp\npp.exe"
"%temp%\vmsetup\temp\npp.exe" /S
CALL :CLEANUP
CALL :FINISHTASK "installing Notepad++"

:PROCEXP
cls
echo Downloading Process Explorer...
call :DOWNLOAD "https://download.sysinternals.com/files/ProcessExplorer.zip" "%temp%\vmsetup\temp\procexp.zip"
"%temp%\vmsetup\extract.vbs" "%temp%\vmsetup\temp\procexp.zip" "%appdata%\procexp"
start "" "%appdata%\procexp\procexp.exe"
CALL :CLEANUP
CALL :FINISHTASK "installing Process Explorer"

:DSM
cls
echo Stopping Superfetch...
sc stop SysMain>nul
sc config SysMain start=disabled 2>nul
CALL :FINISHTASK "disabling Superfetch"

:DDO
cls
echo Stopping Deliver Optimization Services...
sc stop DoSvc>nul
sc config DoSvc start=disabled 2>nul
CALL :FINISHTASK "disabling Delivery Optimization Services"

:RHF
cls
echo # Copyright (c) 1993-2009 Microsoft Corp. > C:\Windows\System32\drivers\etc\hosts
echo # >> C:\Windows\System32\drivers\etc\hosts
echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows. >> C:\Windows\System32\drivers\etc\hosts
echo # >> C:\Windows\System32\drivers\etc\hosts
echo # This file contains the mappings of IP addresses to host names. Each >> C:\Windows\System32\drivers\etc\hosts
echo # entry should be kept on an individual line. The IP address should >> C:\Windows\System32\drivers\etc\hosts
echo # be placed in the first column followed by the corresponding host name. >> C:\Windows\System32\drivers\etc\hosts
echo # The IP address and the host name should be separated by at least one >> C:\Windows\System32\drivers\etc\hosts
echo # space. >> C:\Windows\System32\drivers\etc\hosts
echo # >> C:\Windows\System32\drivers\etc\hosts
echo # Additionally, comments (such as these) may be inserted on individual >> C:\Windows\System32\drivers\etc\hosts
echo # lines or following the machine name denoted by a '#' symbol. >> C:\Windows\System32\drivers\etc\hosts
echo # >> C:\Windows\System32\drivers\etc\hosts
echo # For example: >> C:\Windows\System32\drivers\etc\hosts
echo # >> C:\Windows\System32\drivers\etc\hosts
echo #      102.54.94.97     rhino.acme.com          # source server >> C:\Windows\System32\drivers\etc\hosts
echo #       38.25.63.10     x.acme.com              # x client host >> C:\Windows\System32\drivers\etc\hosts
echo  >> C:\Windows\System32\drivers\etc\hosts
echo # localhost name resolution is handled within DNS itself. >> C:\Windows\System32\drivers\etc\hosts
echo #	127.0.0.1       localhost >> C:\Windows\System32\drivers\etc\hosts
echo #	::1             localhost >> C:\Windows\System32\drivers\etc\hosts
CALL :FINISHTASK "resetting hosts file"

:EADMIN
cls
echo Enabling Administrator Account...
net user administrator /active:yes
CALL :FINISHTASK "enabling Administrator Account"

:DADMIN
cls
echo Enabling Administrator Account...
net user administrator /active:no
CALL :FINISHTASK "disabling Administrator Account"

:W10SEARCHBOX
cls
echo Please select a search box style (Win10 only)
echo [0] Back to menu
echo [1] Hidden
echo [2] Icon Only
echo [3] Search Box
set /p searchRes="Please select: "
if "%searchRes%" == "" ( GOTO :W10SEARCHBOX )
if "%searchRes%" == "0" (
	GOTO :MENU
)
if "%searchRes%" == "1" (
	CALL :SETW10SEARCH 0
)
if "%searchRes%" == "2" (
	CALL :SETW10SEARCH 1
)
if "%searchRes%" == "3" (
	CALL :SETW10SEARCH 2
)

taskkill /F /IM explorer.exe >nul 2>&1
start explorer.exe
CALL :FINISHTASK "setting search style."

:VCREDIST
cls
echo Installing vcredist...
call :DOWNLOAD "https://aka.ms/vs/17/release/vc_redist.x86.exe" "%temp%\vmsetup\temp\17_vc_redist_x86.exe"
call :DOWNLOAD "https://aka.ms/vs/17/release/vc_redist.x64.exe" "%temp%\vmsetup\temp\17_vc_redist_x64.exe"
call :DOWNLOAD "https://aka.ms/highdpimfc2013x86enu" "%temp%\vmsetup\temp\13_vc_redist_x86.exe"
call :DOWNLOAD "https://aka.ms/highdpimfc2013x64enu" "%temp%\vmsetup\temp\13_vc_redist_x64.exe"
call :DOWNLOAD "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe" "%temp%\vmsetup\temp\12_vc_redist_x86.exe"
call :DOWNLOAD "https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe" "%temp%\vmsetup\temp\12_vc_redist_x64.exe"
call :DOWNLOAD "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe" "%temp%\vmsetup\temp\10_vc_redist_x86.exe"
call :DOWNLOAD "https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe" "%temp%\vmsetup\temp\10_vc_redist_x64.exe"
call :DOWNLOAD "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe" "%temp%\vmsetup\temp\08_vc_redist_x86.exe"
call :DOWNLOAD "https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe" "%temp%\vmsetup\temp\08_vc_redist_x64.exe"

if not "%isWinXP%" == "true" (
	"%temp%\vmsetup\temp\17_vc_redist_x86.exe" /q /norestart
	"%temp%\vmsetup\temp\17_vc_redist_x64.exe" /q /norestart
)
"%temp%\vmsetup\temp\13_vc_redist_x86.exe" /q /norestart
"%temp%\vmsetup\temp\13_vc_redist_x64.exe" /q /norestart
"%temp%\vmsetup\temp\10_vc_redist_x86.exe" /q /norestart
"%temp%\vmsetup\temp\10_vc_redist_x64.exe" /q /norestart
"%temp%\vmsetup\temp\08_vc_redist_x86.exe" /q /norestart
"%temp%\vmsetup\temp\08_vc_redist_x64.exe" /q /norestart
CALL :CLEANUP
CALL :FINISHTASK "installing Microsoft Visual C++ Redistributable"

:AJDK
cls
echo Select Java Version:
echo     [0] Return to menu
call :CHECKBOX "%java8%" "[1] Java 8"
call :CHECKBOX "%java11%" "[2] Java 11"
call :CHECKBOX "%java16%" "[3] Java 16"
call :CHECKBOX "%java17%" "[4] Java 17"
call :CHECKBOX "%java18%" "[5] Java 18"
echo      [6] Select all Java Version
echo     [Enter] Install selected Java version
set /p ver="Java Version: "
if "%ver%" == "0" (
	GOTO :MENU
)

if "%ver%" == "1" (
	call :TOGGLEVARIABLE java8
)
if "%ver%" == "2" (
	call :TOGGLEVARIABLE java11
)
if "%ver%" == "3" (
	call :TOGGLEVARIABLE java16
)
if "%ver%" == "4" (
	call :TOGGLEVARIABLE java17
)
if "%ver%" == "5" (
	call :TOGGLEVARIABLE java18
)

if "%ver%" == "6" (
	set java8=1
	set java11=1
	set java16=1
	set java17=1
	set java18=1
)

if "%ver%" == "" (
	If "%PROCESSOR_ARCHITECTURE%" == "AMD64" (set arch=x64) ELSE If "%PROCESSOR_ARCHITECTURE%" == "ARM64" (set arch=aarch64) ELSE set arch=x86
	echo Installing Adoptium JDK...
	if "%java8%" == "1" (
		call :DOWNLOAD "https://api.adoptium.net/v3/installer/latest/8/ga/windows/%arch%/jdk/hotspot/normal/eclipse" "%temp%\vmsetup\temp\ajdk8-%arch%.msi"
	)
	if "%java11%" == "1" (
		call :DOWNLOAD "https://api.adoptium.net/v3/installer/latest/11/ga/windows/%arch%/jdk/hotspot/normal/eclipse" "%temp%\vmsetup\temp\ajdk11-%arch%.msi"
	)
	if "%java16%" == "1" (
		call :DOWNLOAD "https://api.adoptium.net/v3/installer/latest/16/ga/windows/%arch%/jdk/hotspot/normal/eclipse" "%temp%\vmsetup\temp\ajdk16-%arch%.msi"
	)
	if "%java17%" == "1" (
		call :DOWNLOAD "https://api.adoptium.net/v3/installer/latest/17/ga/windows/%arch%/jdk/hotspot/normal/eclipse" "%temp%\vmsetup\temp\ajdk17-%arch%.msi"
	)
	if "%java18%" == "1" (
		call :DOWNLOAD "https://api.adoptium.net/v3/installer/latest/18/ga/windows/%arch%/jdk/hotspot/normal/eclipse" "%temp%\vmsetup\temp\ajdk18-%arch%.msi"
	)
	
	if "%java8%" == "1" (
		msiexec /i "%temp%\vmsetup\temp\ajdk8-%arch%.msi" /qn /norestart
	)
	if "%java11%" == "1" (
		msiexec /i "%temp%\vmsetup\temp\ajdk11-%arch%.msi" /qn /norestart
	)
	if "%java16%" == "1" (
		msiexec /i "%temp%\vmsetup\temp\ajdk16-%arch%.msi" /qn /norestart
	)
	if "%java17%" == "1" (
		msiexec /i "%temp%\vmsetup\temp\ajdk17-%arch%.msi" /qn /norestart
	)
	if "%java18%" == "1" (
		msiexec /i "%temp%\vmsetup\temp\ajdk18-%arch%.msi" /qn /norestart
	)
	
	CALL :CLEANUP
	CALL :FINISHTASK "installing Adoptium JDK"
) else (
	GOTO :AJDK
)


:NETFRAMEWORK
cls
echo This section is for installing .NET Framework.
echo Please go back if you want to install .NET (.NET Core)
echo;
echo     [0] Return to menu
call :CHECKBOX "%ndp35%" "[1] .NET Framework 3.5 SP1"
call :CHECKBOX "%ndp40%" "[2] .NET Framework 4.0"
call :CHECKBOX "%ndp452%" "[3] .NET Framework 4.5.2"
call :CHECKBOX "%ndp461%" "[4] .NET Framework 4.6.1"
call :CHECKBOX "%ndp462%" "[5] .NET Framework 4.6.2"
call :CHECKBOX "%ndp47%" "[6] .NET Framework 4.7"
call :CHECKBOX "%ndp471%" "[7] .NET Framework 4.7.1"
call :CHECKBOX "%ndp472%" "[8] .NET Framework 4.7.2"
call :CHECKBOX "%ndp48%" "[9] .NET Framework 4.8"
call :CHECKBOX "%ndp481%" "[10] .NET Framework 4.8.1"
echo     [11] Select all .NET Framework
echo     [Enter] Install selected .NET Framework
set ver=
set /p ver="Please select: "
if "%ver%" == "0" (
	GOTO :MENU
)
if "%ver%" == "1" (
	call :TOGGLEVARIABLE ndp35
)
if "%ver%" == "2" (
	call :TOGGLEVARIABLE ndp40
)
if "%ver%" == "3" (
	call :TOGGLEVARIABLE ndp452
)
if "%ver%" == "4" (
	call :TOGGLEVARIABLE ndp461
)
if "%ver%" == "5" (
	call :TOGGLEVARIABLE ndp462
)
if "%ver%" == "6" (
	call :TOGGLEVARIABLE ndp47
)
if "%ver%" == "7" (
	call :TOGGLEVARIABLE ndp471
)
if "%ver%" == "8" (
	call :TOGGLEVARIABLE ndp472
)
if "%ver%" == "9" (
	call :TOGGLEVARIABLE ndp48
)
if "%ver%" == "10" (
	call :TOGGLEVARIABLE ndp481
)

if "%ver%" == "11" (
	set "ndp35=1"
	set "ndp40=1"
	set "ndp452=1"
	set "ndp461=1"
	set "ndp462=1"
	set "ndp47=1"
	set "ndp471=1"
	set "ndp472=1"
	set "ndp48=1"
	set "ndp481=1"
)

if "%ver%" == "" (
	cls
	echo Downloading selected .NET Framework...
	if "%ndp35%" == "1" (
		call :DOWNLOAD "https://download.microsoft.com/download/2/0/e/20e90413-712f-438c-988e-fdaa79a8ac3d/dotnetfx35.exe" "%temp%\vmsetup\temp\ndp35.exe"
	)
	if "%ndp40%" == "1" (
		call :DOWNLOAD "https://download.microsoft.com/download/9/5/A/95A9616B-7A37-4AF6-BC36-D6EA96C8DAAE/dotNetFx40_Full_x86_x64.exe" "%temp%\vmsetup\temp\ndp40.exe"
	)
	if "%ndp452%" == "1" (
		call :DOWNLOAD "https://download.microsoft.com/download/E/2/1/E21644B5-2DF2-47C2-91BD-63C560427900/NDP452-KB2901907-x86-x64-AllOS-ENU.exe" "%temp%\vmsetup\temp\ndp452.exe"
	)
	if "%ndp461%" == "1" (
		call :DOWNLOAD "https://download.microsoft.com/download/E/4/1/E4173890-A24A-4936-9FC9-AF930FE3FA40/NDP461-KB3102436-x86-x64-AllOS-ENU.exe" "%temp%\vmsetup\temp\ndp461.exe"
	)
	if "%ndp462%" == "1" (
		call :DOWNLOAD "https://download.visualstudio.microsoft.com/download/pr/8e396c75-4d0d-41d3-aea8-848babc2736a/80b431456d8866ebe053eb8b81a168b3/ndp462-kb3151800-x86-x64-allos-enu.exe" "%temp%\vmsetup\temp\ndp462.exe"
	)
	if "%ndp47%" == "1" (
		call :DOWNLOAD "https://download.visualstudio.microsoft.com/download/pr/2dfcc711-bb60-421a-a17b-76c63f8d1907/e5c0231bd5d51fffe65f8ed7516de46a/ndp47-kb3186497-x86-x64-allos-enu.exe" "%temp%\vmsetup\temp\ndp47.exe"
	)
	if "%ndp471%" == "1" (
		call :DOWNLOAD "https://download.visualstudio.microsoft.com/download/pr/4312fa21-59b0-4451-9482-a1376f7f3ba4/9947fce13c11105b48cba170494e787f/ndp471-kb4033342-x86-x64-allos-enu.exe" "%temp%\vmsetup\temp\ndp471.exe"
	)
	if "%ndp472%" == "1" (
		call :DOWNLOAD "https://download.visualstudio.microsoft.com/download/pr/1f5af042-d0e4-4002-9c59-9ba66bcf15f6/089f837de42708daacaae7c04b7494db/ndp472-kb4054530-x86-x64-allos-enu.exe" "%temp%\vmsetup\temp\ndp472.exe"
	)
	if "%ndp48%" == "1" (
		call :DOWNLOAD "https://download.visualstudio.microsoft.com/download/pr/2d6bb6b2-226a-4baa-bdec-798822606ff1/8494001c276a4b96804cde7829c04d7f/ndp48-x86-x64-allos-enu.exe" "%temp%\vmsetup\temp\ndp48.exe"
	)
	if "%ndp481%" == "1" (
		call :DOWNLOAD "https://download.visualstudio.microsoft.com/download/pr/6f083c7e-bd40-44d4-9e3f-ffba71ec8b09/3951fd5af6098f2c7e8ff5c331a0679c/ndp481-x86-x64-allos-enu.exe" "%temp%\vmsetup\temp\ndp481.exe"
	)
	
	echo Installing selected .NET Framework...
	
	if "%ndp35%" == "1" (
		"%temp%\vmsetup\temp\ndp35.exe" /q /norestart
	)
	if "%ndp40%" == "1" (
		"%temp%\vmsetup\temp\ndp40.exe" /q /norestart
	)
	if "%ndp452%" == "1" (
		"%temp%\vmsetup\temp\ndp452.exe" /q /norestart
	)
	if "%ndp461%" == "1" (
		"%temp%\vmsetup\temp\ndp461.exe" /q /norestart
	)
	if "%ndp462%" == "1" (
		"%temp%\vmsetup\temp\ndp462.exe" /q /norestart
	)
	if "%ndp47%" == "1" (
		"%temp%\vmsetup\temp\ndp47.exe" /q /norestart
	)
	if "%ndp471%" == "1" (
		"%temp%\vmsetup\temp\ndp471.exe" /q /norestart
	)
	if "%ndp472%" == "1" (
		"%temp%\vmsetup\temp\ndp472.exe" /q /norestart
	)
	if "%ndp48%" == "1" (
		"%temp%\vmsetup\temp\ndp48.exe" /q /norestart
	)
	if "%ndp481%" == "1" (
		"%temp%\vmsetup\temp\ndp481.exe" /q /norestart
	)
	
	call :CLEANUP
	call :FINISHTASK "installing .NET Framework"
) else (
	GOTO :NETFRAMEWORK
)


:CHECKBOX
if "%~1" == "1" (
	echo [x] %~2
) else (
	echo [ ] %~2
)
GOTO :EOF

:TOGGLEVARIABLE
set p=%~1
if "!%p%!" == "1" (
	set "%p%=0"
) else (
	
	set "%p%=1"
)
GOTO :EOF


:SETW10SEARCH
reg add "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" /v SearchboxTaskbarMode /t REG_DWORD /d %~1 /f >nul 2>&1

:DOWNLOAD
if exist "%temp%\vmsetup\wget.exe" (
	"%temp%\vmsetup\wget.exe" -q --show-progress "%~1" -O "%~2"
) else (
	"%temp%\vmsetup\download.vbs" "%~1" "%~2"
	if '%errorlevel%' == '1' (
		echo ===== Download failed! =====
		echo URL: %~1
		echo Destination: %~2
		echo;
		echo Please check your internet connection, and try again.
		echo;
		echo [1] Abort
		echo [2] Retry
		echo [3] Open in browser
		set /p dlres="Select choice (1): "
		if '!dlres!' == '' ( GOTO :EOF )
		if '!dlres!' == '1' (
			GOTO :EOF
		) else (
			if '!dlres!' == '2' (
				cls
				CALL :DOWNLOAD %~1 %~2
			) else (
				start %~1
			)
		)
	)
)
GOTO :EOF


:FINISHTASK
if not "%unattended%" == "1" (
	cls
	echo Finished %~1.
	timeout /t 2 > NUL
	GOTO :MENU
) else (
	GOTO :EOF
)

:CLEANUP
del "%temp%\vmsetup\temp" /s/q 2>nul
goto :EOF

:EXIT
exit