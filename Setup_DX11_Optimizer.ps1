<#
.SYNOPSIS
    Script tu dong thiet lap toan dien cho TFT va Windows 11 chong Crash / Freeze tren AMD GPU.
.DESCRIPTION
    1. Cau hinh BaseEngine.ini cua Riot Games TFT ve DirectX 11.
    2. Khoa Engine.ini thanh Read-Only.
    3. Thiet lap Registry TdrDelay = 30s.
    4. Xoa sach bo nho dem Shader cu cua AMD.
    5. Gan co tuong thich cho League of Legends.exe va TFTClient-Win64-Shipping.exe.
#>

[CmdletBinding()]
param()

Write-Host "=== DANG CAU HINH HE THONG VA GAME DTCL ===" -ForegroundColor Cyan

# 1. Kiem tra quyen Admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Warning "Khuyen nghi chay script nay duoi quyen Administrator de cap nhat Registry TdrDelay."
}

# 2. Cau hinh BaseEngine.ini
$baseEnginePath = "E:\Riot Games\Teamfight Tactics\Live\Engine\Config\BaseEngine.ini"
if (Test-Path $baseEnginePath) {
    Write-Host "[1/5] Dang cau hinh BaseEngine.ini..." -ForegroundColor Yellow
    $content = Get-Content $baseEnginePath -Raw
    if ($content -notmatch "DefaultGraphicsRHI=DefaultGraphicsRHI_DX11") {
        $content = $content.Replace("[/Script/WindowsTargetPlatform.WindowsTargetSettings]", "[/Script/WindowsTargetPlatform.WindowsTargetSettings]`r`nDefaultGraphicsRHI=DefaultGraphicsRHI_DX11")
    }
    if ($content -notmatch "r\.RHIName=D3D11") {
        $content = $content.Replace("[SystemSettings]`r`n", "[SystemSettings]`r`nr.RHIName=D3D11`r`nr.D3D12.Enable=0`r`n")
    }
    Set-Content -Path $baseEnginePath -Value $content -NoNewline
    Write-Host "   -> Da khoa DirectX 11 trong BaseEngine.ini" -ForegroundColor Green
}

# 3. Khoa Engine.ini
$userEnginePath = "$env:LOCALAPPDATA\TFT\Saved\Config\WindowsClient\Engine.ini"
Write-Host "[2/5] Dang khoa Engine.ini..." -ForegroundColor Yellow
if (Test-Path $userEnginePath) {
    Set-ItemProperty -Path $userEnginePath -Name IsReadOnly -Value $false
} else {
    $parentDir = Split-Path $userEnginePath
    if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
}
$engineIniText = @"
[/Script/WindowsTargetPlatform.WindowsTargetSettings]
DefaultGraphicsRHI=DefaultGraphicsRHI_DX11

[SystemSettings]
r.RHIName=D3D11
r.D3D12.Enable=0

[GameNetDriver StatelessConnectHandlerComponent]
CachedClientID=4
"@
Set-Content -Path $userEnginePath -Value $engineIniText -Encoding UTF8
Set-ItemProperty -Path $userEnginePath -Name IsReadOnly -Value $true
Write-Host "   -> Da khoa Engine.ini (Read-Only)" -ForegroundColor Green

# 4. Cap nhat AppCompatFlags
Write-Host "[3/5] Dang gan co tuong thich chong lag..." -ForegroundColor Yellow
$regPath = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
$targets = @(
    "E:\Riot Games\Teamfight Tactics\Live\TFT\Binaries\Win64\TFTClient-Win64-Shipping.exe",
    "E:\Riot Games\Teamfight Tactics\Live\TFTClient.exe",
    "E:\Riot Games\League of Legends\Game\League of Legends.exe"
)
foreach ($t in $targets) {
    if (Test-Path $t) {
        Set-ItemProperty -Path $regPath -Name $t -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE HIGHDPIAWARE" -Force
        Write-Host "   -> Da gan co cho: $(Split-Path $t -Leaf)" -ForegroundColor Green
    }
}

# 5. Registry TdrDelay (Neu co quyen Admin)
Write-Host "[4/5] Kiem tra Registry TdrDelay..." -ForegroundColor Yellow
if ($isAdmin) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrDelay" -Value 30 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrDdiDelay" -Value 30 -Type DWord
    Write-Host "   -> Da nang TdrDelay len 30s thanh cong" -ForegroundColor Green
} else {
    Write-Host "   -> Bo qua TdrDelay (se duoc cap nhat qua file bat Admin)" -ForegroundColor DarkGray
}

# 6. Don sach Shader Cache
Write-Host "[5/5] Dang don sach Shader Cache AMD..." -ForegroundColor Yellow
Remove-Item -Path "$env:LOCALAPPDATA\AMD\DxcCache\*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\AMD\DxCache\*" -Force -ErrorAction SilentlyContinue
Write-Host "   -> Da don sach Shader Cache AMD" -ForegroundColor Green

Write-Host "`n=== TAT CA DA HOAN TAT! BAN CO THE CHOI GAME NGAY ===" -ForegroundColor Cyan
