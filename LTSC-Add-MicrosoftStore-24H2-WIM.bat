@echo off
chcp 65001 >nul
setlocal EnableExtensions

title Вшивание Microsoft Store в WIM/VHD - Windows 11 LTSC 24H2

:: =========================================================
:: LTSC Add Microsoft Store 24H2 WIM
:: Установка Microsoft Store в offline-образ Windows 11 LTSC 2024/24H2
:: Автор: NaitSide
:: GitHub: https://github.com/NaitSide/
:: =========================================================

:: Проверка прав администратора
net session >nul 2>&1
if %errorlevel% neq 0 (
    cls
    echo.
    echo =========================================================
    echo    [ОШИБКА] Требуются права администратора!
    echo =========================================================
    echo.
    echo    Запустите скрипт правой кнопкой мыши
    echo    -^> "Запуск от имени администратора"
    echo.
    echo =========================================================
    echo.
    pause
    exit /b 1
)

cls
echo.
echo =========================================================
echo    LTSC Add Microsoft Store 24H2 WIM
echo    Вшивание Microsoft Store в offline WIM/VHD-образ
echo    Автор: NaitSide
echo    github.com/NaitSide
echo =========================================================
echo.
echo    Этот скрипт установит в offline-образ:
echo.
echo    - Microsoft Store
echo    - Store Purchase App
echo    - Desktop App Installer / winget
echo    - Необходимые зависимости x64 для Windows 11 24H2
echo.
echo    [!] Перед запуском разверните WIM на диск через DISM++
echo    [!] Укажите букву диска, где находится папка Windows
echo.
echo =========================================================
echo    Источник пакетов: LTSC-Add-MicrosoftStore 24H2 github.com/minihub
echo =========================================================
echo.
pause

:: Переходим в каталог скрипта
pushd "%~dp0"
set "ScriptDir=%CD%"
set "PackagesDir=%ScriptDir%\Packages"

:INPUT_DRIVE
echo.
set /p TargetDrive="Введите букву диска VHD/развернутого образа Windows, например F: "

:: Нормализация буквы диска
set "TargetDrive=%TargetDrive::=%"
set "TargetDrive=%TargetDrive: =%"
set "ImagePath=%TargetDrive%:"

if not exist "%ImagePath%\" (
    echo.
    echo [ОШИБКА] Диск %ImagePath% не найден. Проверьте, что VHD смонтирован.
    goto INPUT_DRIVE
)

if not exist "%ImagePath%\Windows\System32" (
    echo.
    echo [ОШИБКА] На диске %ImagePath% не найдена Windows: %ImagePath%\Windows\System32
    echo Возможно, выбрана не та буква диска.
    goto INPUT_DRIVE
)

if not exist "%PackagesDir%\" (
    echo.
    echo [ОШИБКА] Не найдена папка Packages рядом со скриптом:
    echo %PackagesDir%
    echo.
    pause
    exit /b 1
)

:: =========================================================
:: Пакеты Windows 11 24H2 / LTSC 2024
:: =========================================================

set "WinStore=%PackagesDir%\Microsoft.WindowsStore_8wekyb3d8bbwe.msixbundle"
set "WinStoreXML=%PackagesDir%\Microsoft.WindowsStore_8wekyb3d8bbwe.xml"

set "StorePur=%PackagesDir%\Microsoft.StorePurchaseApp_8wekyb3d8bbwe.appxbundle"
set "StorePurXML=%PackagesDir%\Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml"

set "AppIns=%PackagesDir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
set "AppInsXML=%PackagesDir%\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml"

:: x64 dependencies only. ARM64 packages may exist in Packages, but are ignored for x64 LTSC image.
set "NetFramework=%PackagesDir%\Microsoft.NET.Native.Framework.x64.2.2.appx"
set "NetRuntime=%PackagesDir%\Microsoft.NET.Native.Runtime.x64.2.2.appx"
set "UIXaml=%PackagesDir%\Microsoft.UI.Xaml.x64.2.8.appx"
set "VCLibs=%PackagesDir%\Microsoft.VCLibs.x64.14.00.appx"
set "VCLibsUWP=%PackagesDir%\Microsoft.VCLibs.x64.14.00.UWPDesktop.appx"

:: =========================================================
:: Проверка наличия файлов
:: =========================================================

call :CheckFile "%WinStore%" "Microsoft Store"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%WinStoreXML%" "Microsoft Store License XML"
if errorlevel 1 goto FILE_ERROR

call :CheckFile "%StorePur%" "Store Purchase App"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%StorePurXML%" "Store Purchase App License XML"
if errorlevel 1 goto FILE_ERROR

call :CheckFile "%AppIns%" "Desktop App Installer"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%AppInsXML%" "Desktop App Installer License XML"
if errorlevel 1 goto FILE_ERROR

call :CheckFile "%NetFramework%" "NET Native Framework x64"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%NetRuntime%" "NET Native Runtime x64"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%UIXaml%" "UI.Xaml x64"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%VCLibs%" "VCLibs x64"
if errorlevel 1 goto FILE_ERROR
call :CheckFile "%VCLibsUWP%" "VCLibs UWPDesktop x64"
if errorlevel 1 goto FILE_ERROR

goto INSTALL

:FILE_ERROR
echo.
echo [ОШИБКА] Не хватает одного или нескольких файлов в Packages.
echo Исправьте набор пакетов и запустите скрипт повторно.
echo.
pause
exit /b 1

:INSTALL
echo.
echo =========================================================
echo Начинаем установку компонентов Microsoft Store в %ImagePath%
echo Каталог скрипта: %ScriptDir%
echo Каталог пакетов: %PackagesDir%
echo =========================================================
echo.

:: Зависимости для Store и StorePurchaseApp
set DepsStore=/DependencyPackagePath:"%NetFramework%" /DependencyPackagePath:"%NetRuntime%" /DependencyPackagePath:"%UIXaml%" /DependencyPackagePath:"%VCLibs%" /DependencyPackagePath:"%VCLibsUWP%"

:: Зависимости для DesktopAppInstaller / winget
set DepsAppInstaller=/DependencyPackagePath:"%UIXaml%" /DependencyPackagePath:"%VCLibs%" /DependencyPackagePath:"%VCLibsUWP%"

:: =========================================================
:: Установка компонентов по порядку оригинального 24H2-пакета
:: =========================================================

echo.
echo [1/3] Установка Microsoft Store...
dism /English /Image:"%ImagePath%" /Add-ProvisionedAppxPackage /PackagePath:"%WinStore%" %DepsStore% /LicensePath:"%WinStoreXML%"
if %errorlevel% neq 0 (
    echo.
    echo [ОШИБКА] Microsoft Store не установлен. Код ошибки: %errorlevel%
    goto INSTALL_FAILED
)

echo.
echo [2/3] Установка Store Purchase App...
dism /English /Image:"%ImagePath%" /Add-ProvisionedAppxPackage /PackagePath:"%StorePur%" %DepsStore% /LicensePath:"%StorePurXML%"
if %errorlevel% neq 0 (
    echo.
    echo [ОШИБКА] Store Purchase App не установлен. Код ошибки: %errorlevel%
    goto INSTALL_FAILED
)

echo.
echo [3/3] Установка Desktop App Installer / winget...
dism /English /Image:"%ImagePath%" /Add-ProvisionedAppxPackage /PackagePath:"%AppIns%" %DepsAppInstaller% /LicensePath:"%AppInsXML%"
if %errorlevel% neq 0 (
    echo.
    echo [ОШИБКА] Desktop App Installer не установлен. Код ошибки: %errorlevel%
    goto INSTALL_FAILED
)

:: =========================================================
:: Проверка результата
:: =========================================================

echo.
echo =========================================================
echo Проверка provisioned AppX-пакетов в образе...
echo =========================================================
echo.

set "VerifyLog=%TEMP%\ltsc_store_verify_%RANDOM%.txt"
dism /English /Image:"%ImagePath%" /Get-ProvisionedAppxPackages > "%VerifyLog%" 2>&1

findstr /i /c:"Microsoft.WindowsStore" "%VerifyLog%" >nul
if %errorlevel% equ 0 (
    echo [OK] Microsoft.WindowsStore найден в provisioned packages.
) else (
    echo [WARN] Microsoft.WindowsStore не найден в provisioned packages.
)

findstr /i /c:"Microsoft.StorePurchaseApp" "%VerifyLog%" >nul
if %errorlevel% equ 0 (
    echo [OK] Microsoft.StorePurchaseApp найден в provisioned packages.
) else (
    echo [WARN] Microsoft.StorePurchaseApp не найден в provisioned packages.
)

findstr /i /c:"Microsoft.DesktopAppInstaller" "%VerifyLog%" >nul
if %errorlevel% equ 0 (
    echo [OK] Microsoft.DesktopAppInstaller найден в provisioned packages.
) else (
    echo [WARN] Microsoft.DesktopAppInstaller не найден в provisioned packages.
)

del "%VerifyLog%" >nul 2>&1

echo.
echo =========================================================
echo Установка завершена.
echo Если выше все три компонента имеют статус [OK],
echo базовая интеграция Microsoft Store прошла успешно.
echo =========================================================
echo.
pause
popd
exit /b 0

:INSTALL_FAILED
echo.
echo =========================================================
echo Установка остановлена из-за ошибки DISM.
echo Проверьте код ошибки выше и состояние offline-образа.
echo =========================================================
echo.
pause
popd
exit /b 1

:CheckFile
if not exist "%~1" (
    echo [ОШИБКА] Не найден файл: %~2
    echo %~1
    exit /b 1
)
exit /b 0
