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

GOTO :LSK
GOTO :HOSTS
pause

:LSK
taskkill /F /IM student.exe 2>nul
taskkill /F /IM LskHelper.exe 2>nul

:TASKMGR
echo Windows Registry Editor Version 5.00 > 1.reg
echo [HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\System] >> 1.reg
echo "DisableTaskMgr"=dword:00000000 >> 1.reg
regedit /s 1.reg
gpupdate /force

:HOSTS
del C:\Windows\System32\drivers\etc\hosts /f/s/q