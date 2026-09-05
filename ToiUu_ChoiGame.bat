@echo off
chcp 65001 >nul
title TOI UU VA CUU HO TREO GAME DTCL (TFT)

:: 1. Tu dong yeu cau quyen Administrator (Su dung duong dan 8.3 ngan gon de chong loi tieng Viet co dau nhu "May tinh")
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Dang yeu cau quyen Administrator...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process cmd -ArgumentList '/c `\"%~s0`\"' -Verb RunAs"
    exit /b
)

echo ====================================================================
echo      DANG KICH HOAT BO TOI UU VA CHONG CRASH CHO DAU TRUONG CHAN LY
echo ====================================================================
echo.

:: 1. Tat tat ca tien trinh game bi treo do
echo [1/5] Dang don dep tien trinh game bi treo (TFT, League, Riot)...
taskkill /F /IM TFTClient-Win64-Shipping.exe >nul 2>&1
taskkill /F /IM TFTClient.exe >nul 2>&1
taskkill /F /IM "League of Legends.exe" >nul 2>&1
taskkill /F /IM LeagueCrashHandler.exe >nul 2>&1

:: 2. Tang kha nang chiu tai GPU (TdrDelay = 30 giay)
echo [2/5] Dang tang thoi gian cho GPU (TdrDelay = 30s - Chong ngat card tuyet doi)...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDelay /t REG_DWORD /d 30 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v TdrDdiDelay /t REG_DWORD /d 30 /f >nul 2>&1

:: 3. Xoa sach bo nho dem Shader cu bi loi (DxcCache & DxCache)
echo [3/5] Dang xoa sach bo nho dem Shader AMD bi loi (Reset Shader Cache)...
del /f /q /s "%LOCALAPPDATA%\AMD\DxcCache\*" >nul 2>&1
del /f /q /s "%LOCALAPPDATA%\AMD\DxCache\*" >nul 2>&1

:: 4. Tat cac ung dung ngam nguyen nhan gay xung dot RAM va Vanguard
echo [4/5] Dang tat BlueStacks, Docker, WSL, VMware va Overwolf...
taskkill /F /IM BlueStacksServices.exe >nul 2>&1
taskkill /F /IM HD-Player.exe >nul 2>&1
taskkill /F /IM BstkSVC.exe >nul 2>&1
wsl --shutdown >nul 2>&1
taskkill /F /IM "Docker Desktop.exe" >nul 2>&1
taskkill /F /IM com.docker.backend.exe >nul 2>&1
taskkill /F /IM vmware-authd.exe >nul 2>&1
taskkill /F /IM vmware-tray.exe >nul 2>&1
taskkill /F /IM vmware-usbarbitrator64.exe >nul 2>&1
taskkill /F /IM OverwolfLauncher.exe >nul 2>&1
taskkill /F /IM Overwolf.exe >nul 2>&1
taskkill /F /IM MetaTFT.exe >nul 2>&1

:: 5. Tu dong quet tat ca o dia (C, D, E, ...) va khoa DirectX 11 vao Engine cua TFT
echo [5/5] Dang tu dong tim thu muc game tren moi o dia va khoa DirectX 11...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$yaml = 'C:\ProgramData\Riot Games\Metadata\teamfighttactics.live\teamfighttactics.live.product_settings.yaml'; $tft = $null; if (Test-Path $yaml) { $l = Get-Content $yaml | Select-String 'product_install_full_path:'; if ($l -match 'product_install_full_path:\s*\"(.*)\"') { $p = $matches[1].Replace('/','\'); if (Test-Path \"$p\Engine\Config\BaseEngine.ini\") { $tft = $p } } }; if (-not $tft) { $drives = (Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3').DeviceID; foreach ($d in $drives) { $p = \"$d\Riot Games\Teamfight Tactics\Live\"; if (Test-Path \"$p\Engine\Config\BaseEngine.ini\") { $tft = $p; break } } }; if ($tft) { $base = Join-Path $tft 'Engine\Config\BaseEngine.ini'; $c = Get-Content $base -Raw; $m = $false; if ($c -notmatch 'DefaultGraphicsRHI=DefaultGraphicsRHI_DX11') { $c = $c.Replace('[/Script/WindowsTargetPlatform.WindowsTargetSettings]', \"[/Script/WindowsTargetPlatform.WindowsTargetSettings]`r`nDefaultGraphicsRHI=DefaultGraphicsRHI_DX11\"); $m = $true }; if ($c -notmatch 'r\.RHIName=D3D11') { $c = $c.Replace(\"[SystemSettings]`r`n\", \"[SystemSettings]`r`nr.RHIName=D3D11`r`nr.D3D12.Enable=0`r`n\"); $m = $true }; if ($m) { Set-Content -Path $base -Value $c -NoNewline } }; $ini = \"$env:LOCALAPPDATA\TFT\Saved\Config\WindowsClient\Engine.ini\"; $dir = Split-Path $ini; if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }; if (Test-Path $ini) { Set-ItemProperty -Path $ini -Name IsReadOnly -Value $false }; $txt = \"[/Script/WindowsTargetPlatform.WindowsTargetSettings]`r`nDefaultGraphicsRHI=DefaultGraphicsRHI_DX11`r`n`r`n[SystemSettings]`r`nr.RHIName=D3D11`r`nr.D3D12.Enable=0`r`n`r`n[GameNetDriver StatelessConnectHandlerComponent]`r`nCachedClientID=4\"; Set-Content -Path $ini -Value $txt -Encoding UTF8; Set-ItemProperty -Path $ini -Name IsReadOnly -Value $true" >nul 2>&1

echo.
echo ====================================================================
echo   HOAN TAT! DA QUET DUONG DAN VA TOI UU CHO HE THONG THANH CONG!
echo   Bao gom:
echo     [v] Tu dong quet tim game tren moi o dia (C:, D:, E:, ...).
echo     [v] TdrDelay = 30 giay (GPU load nang khong bao gio bi Windows kill).
echo     [v] Ep chuyen sang DirectX 11 on dinh (Loai bo loi D3D12).
echo     [v] Xoa sach Shader Cache bi loi cua AMD.
echo     [v] Giai phong RAM tu BlueStacks, WSL & VMware.
echo.
echo   -> Bay gio ban co the mo Riot Client va vao game choi thoai mai!
echo ====================================================================
echo.
echo Nhan phim ENTER de thoat...
pause >nul
