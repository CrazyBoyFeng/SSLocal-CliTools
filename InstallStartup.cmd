@Echo off
SetLocal EnableDelayedExpansion
Title %~n0
CD /D "%~dp0"

Shadowsocks.cmd Install
Pause