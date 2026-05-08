@echo off
title Game Builder

:: Переходим в папку со скриптом
cd /d "%~dp0"

:: Проверяем исходник
if not exist guess.asm (
    echo ERROR: guess.asm not found!
    pause
    exit /b 1
)

:: Если nasm.exe лежит в подпапке, перемещаем его в tools\
if exist tools\nasm-2.16.01\nasm.exe (
    echo Moving nasm.exe to tools folder...
    if not exist tools mkdir tools
    move /Y tools\nasm-2.16.01\nasm.exe tools\nasm.exe >nul
)

:: Если golink.exe лежит где-то в подпапке, тоже перемещаем
for /d %%i in (tools\GoLink*) do (
    if exist %%i\golink.exe (
        echo Moving golink.exe to tools folder...
        move /Y %%i\golink.exe tools\golink.exe >nul
    )
)

:: Проверяем, что всё на месте
if not exist tools\nasm.exe (
    echo ERROR: nasm.exe not found in tools folder or its subfolders.
    echo Please put nasm.exe into 'tools' folder.
    pause
    exit /b 1
)

if not exist tools\golink.exe (
    echo ERROR: golink.exe not found.
    echo Please put golink.exe into 'tools' folder.
    pause
    exit /b 1
)

:: Сборка
echo Assembling with NASM...
tools\nasm.exe -f win64 guess.asm -o guess.obj
if errorlevel 1 (
    echo Assembly failed.
    pause
    exit /b 1
)

echo Linking with GoLink...
tools\golink.exe /entry:main /console guess.obj /fo guess.exe kernel32.dll
if errorlevel 1 (
    echo Linking failed.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Game successfully built! Starting...
echo ========================================
guess.exe
echo.
echo Game finished. Press any key to exit.
pause >nul
exit /b 0