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
    GoTo :EOF
) Else If /I "%1"=="Remove" (
    TaskKill /F /IM sslocal*
    TaskKill /F /IM v2ray-plugin*
    Call :DisableProxy
    Pause
    GoTo :EOF
)

Set Local=0.0.0.0
Set LocalPort=1080
Set Server=Server.Address
Set ServerPort=443
Set ServerPath=/
Set Method=plain
Set Password=Password
Set Direct=*.baidu.com;*.qq.com

Call :EnableProxy
Echo 启动 %~n0
sslocal.exe -v --protocol "http" -b "!Local!:!LocalPort!" -s "!Server!:!ServerPort!" -m "!Method!" -k "!Password!" --plugin "v2ray-plugin" --plugin-opts "tls;host=!Server!;path=!ServerPath!" --acl "bypass-lan-china.acl"
Set ExitCode=!ErrorLevel!
Call :DisableProxy
If Not "!ExitCode!"=="0" (
    Echo Exit Code: !ExitCode!
)
Pause
Exit !ExitCode!

:EnableProxy
Echo 设置代理
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "!Direct!;<local>" /f >NUL
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "localhost:!LocalPort!" /f >NUL
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 1 /f >NUL
Reg Delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v AutoConfigURL /f >NUL 2>NUL
GoTo :EOF

:DisableProxy
Echo 取消代理
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyEnable /t REG_DWORD /d 0 /f >NUL
Rem Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyServer /d "" /f >NUL
Rem Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ProxyOverride /t REG_SZ /d "" /f >NUL
GoTo :EOF

:Install
Echo 开机启动
Reg Add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v %~n0 /t REG_SZ /d "\"%~dpnx0\" Start" /f >NUL
GoTo :EOF