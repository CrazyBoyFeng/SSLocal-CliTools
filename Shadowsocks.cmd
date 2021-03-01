@Echo off
SetLocal EnableDelayedExpansion
Title %~n0
CD /D "%~dp0"

If /I "%1"=="Start" (
    Start /Min Cmd /C "%~dpnx0"
    GoTo :EOF
) Else If /I "%1"=="Install" (
    Call :Install
    Pause
    Exit
) Else If /I "%1"=="Remove" (
    TaskKill /F /IM sslocal*
    Call :DisableProxy
    Pause
    Exit
)

Set proxy=127.0.0.1:1080
Set server=server.host
Set serverport=443
Set serverpath=/
Set method=plain
Set password=password
Set direct=*.baidu.com;*.qq.com

Call :EnableProxy
Echo 启动 %~n0
sslocal.exe -v --protocol "http" -b "!proxy!" -s "!server!:!serverport!" -m "!method!" -k "!password!" --plugin "v2ray-plugin" --plugin-opts "tls;host=!server!;path=!serverpath!" --acl "bypass-lan-china.acl"
Set ExitCode=!ErrorLevel!
Call :DisableProxy
If Not "!ExitCode!"=="0" (
    Echo Exit Code: %ExitCode%
)
Pause
Exit !ExitCode!

:EnableProxy
Echo 设置代理
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "!direct!;<local>" /f >NUL
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "!proxy!" /f >NUL
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >NUL
Reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >NUL 2>NUL
Goto :EOF

:DisableProxy
Echo 取消代理
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >NUL
Rem Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "" /f >NUL
Rem Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f >NUL
Goto :EOF

:Install
Echo 开机启动
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v %~n0 /t REG_SZ /d "\"%~dpnx0\" Start" /f >NUL
Goto :EOF