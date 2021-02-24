@Echo off
Set direct=*.baidu.com;*.qq.com
SetLocal EnableDelayedExpansion
Title %~n0
CD /D "%~dp0"

If "%1"=="Start" (
    Start /Min Cmd /C "%~dpnx0"
    Exit
) Else If "%1"=="Install" (
    Call :Install
    Pause
    Exit
) Else If "%1"=="Remove" (
    TaskKill /F /IM sslocal*
    Call :DisableProxy
    Pause
    Exit
)

Call :EnableProxy
Echo 启动 %~n0
sslocal.exe --protocol "http" -b "127.0.0.1:1080" -s "server:443" -m "plain" -k "password" --plugin "v2ray-plugin" --plugin-opts "tls;host=host;path=/path" --acl "bypass-lan-china.acl"
Set ExitCode=%ErrorLevel%
Call :DisableProxy
If Not "%ExitCode%"=="0" (
    Echo Exit Code: %ExitCode%
)
Pause
Exit %ExitCode%

:EnableProxy
Echo 设置代理
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "%direct%;<local>" /f >NUL
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "127.0.0.1:1080" /f >NUL
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >NUL
REG DELETE "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >NUL
Goto :EOF

:DisableProxy
Echo 取消代理
REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >NUL
Rem REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "" /f >NUL
Rem REG ADD "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f >NUL
Goto :EOF

:Install
Echo 开机启动
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v %~n0 /t REG_SZ /d "%~dpnx0 Start" /f >NUL