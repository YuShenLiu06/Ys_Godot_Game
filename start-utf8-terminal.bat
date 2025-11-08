@echo off
echo 启动UTF-8编码的PowerShell终端...
chcp 65001 >nul
powershell -NoExit -Command "[Console]::OutputEncoding = [System.Text.Encoding]::UTF8; [Console]::InputEncoding = [System.Text.Encoding]::UTF8; $env:PYTHONIOENCODING = 'utf-8'; $env:LANG = 'zh_CN.UTF-8'; $env:LC_ALL = 'zh_CN.UTF-8'; Write-Host 'UTF-8终端已启动，中文显示应该正常了喵～' -ForegroundColor Green"