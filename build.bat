@echo off

py tools/config_style_checker.py
echo ========================================
py tools/sqf_validator.py
echo ========================================

echo Start build? [y]es [n]o
set /p exitout="# "

if NOT %exitout%==y exit
hemtt.exe build

echo [Finished]
pause
