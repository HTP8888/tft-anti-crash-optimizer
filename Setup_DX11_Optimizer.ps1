<#
.SYNOPSIS
    Script tự động tìm kiếm đường dẫn cài đặt và cấu hình tối ưu chống treo/crash ĐTCL (TFT) trên mọi ổ đĩa (C:, D:, E:, ...).
.DESCRIPTION
    1. Tự động quét và phát hiện thư mục cài đặt Riot Games / ĐTCL trên toàn bộ các ổ cứng của máy.
    2. Khóa cứng DirectX 11 thuần cho động cơ Unreal Engine trong BaseEngine.ini.
    3. Thiết lập Engine.ini thành Read-Only để chống game tự đảo ngược về DirectX 12.
    4. Nâng thời gian chống ngắt card đồ họa Windows TdrDelay lên 30 giây.
    5. Gắn cờ vô hiệu hóa Fullscreen Optimizations cho các tệp thực thi.
    6. Dọn sạch rác bộ nhớ đệm Shader Cache cũ của AMD (DxcCache & DxCache).
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$CustomPath = ""
)

Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "   BO CONG CU CAU HINH CHONG TREO MAY CHO DTCL (AMD RYZEN / APU EDITION)" -ForegroundColor Cyan
Write-Host "=========================================================================`n" -ForegroundColor Cyan

# -------------------------------------------------------------------------
# 1. HAM TU DONG TIM KIEM THU MUC CAI DAT TFT & LEAGUE OF LEGENDS
# -------------------------------------------------------------------------
function Get-TFTInstallPath {
    param([string]$UserPath)

    if ($UserPath -and (Test-Path "$UserPath\Engine\Config\BaseEngine.ini")) {
        return $UserPath
    }

    # Cach 1: Doc tu Metadata cua Riot Client (Chinh xac nhat)
    $yamlPath = "C:\ProgramData\Riot Games\Metadata\teamfighttactics.live\teamfighttactics.live.product_settings.yaml"
    if (Test-Path $yamlPath) {
        $line = Get-Content $yamlPath | Select-String "product_install_full_path:"
        if ($line -match 'product_install_full_path:\s*"(.*)"') {
            $metaPath = $matches[1].Replace('/', '\')
            if (Test-Path "$metaPath\Engine\Config\BaseEngine.ini") {
                return $metaPath
            }
        }
    }

    # Cach 2: Quet qua tat ca cac o dia hien co tren may (C, D, E, F, G...)
    $drives = (Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3").DeviceID
    $subPaths = @(
        "Riot Games\Teamfight Tactics\Live",
        "Games\Riot Games\Teamfight Tactics\Live",
        "Program Files\Riot Games\Teamfight Tactics\Live",
        "Program Files (x86)\Riot Games\Teamfight Tactics\Live"
    )

    foreach ($d in $drives) {
        foreach ($sub in $subPaths) {
            $testPath = Join-Path $d $sub
            if (Test-Path "$testPath\Engine\Config\BaseEngine.ini") {
                return $testPath
            }
        }
    }

    return $null
}

function Get-LoLGameExePath {
    # Cach 1: Doc qua Metadata
    $lolYaml = "C:\ProgramData\Riot Games\Metadata\league_of_legends.live\league_of_legends.live.product_settings.yaml"
    if (Test-Path $lolYaml) {
        $line = Get-Content $lolYaml | Select-String "product_install_full_path:"
        if ($line -match 'product_install_full_path:\s*"(.*)"') {
            $lolPath = $matches[1].Replace('/', '\')
            $exe = Join-Path $lolPath "Game\League of Legends.exe"
            if (Test-Path $exe) { return $exe }
        }
    }

    # Cach 2: Quet cac o dia
    $drives = (Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3").DeviceID
    foreach ($d in $drives) {
        $exe = "$d\Riot Games\League of Legends\Game\League of Legends.exe"
        if (Test-Path $exe) { return $exe }
    }

    return $null
}

# -------------------------------------------------------------------------
# 2. THUC THI TIM KIEM THU MUC
# -------------------------------------------------------------------------
Write-Host "[1/6] Dang tu dong quet tim thu muc cai dat game tren cac o dia..." -ForegroundColor Yellow
$tftPath = Get-TFTInstallPath -UserPath $CustomPath

if ($tftPath) {
    Write-Host "   -> Tim thay thu muc TFT tai: $tftPath" -ForegroundColor Green
} else {
    Write-Warning "   Khong tu dong tim thay thu muc cai dat Teamfight Tactics."
    Write-Host "   Ban co the truyen duong dan qua tham so: .\Setup_DX11_Optimizer.ps1 -CustomPath 'D:\Riot Games\Teamfight Tactics\Live'" -ForegroundColor DarkYellow
}

$lolExe = Get-LoLGameExePath
if ($lolExe) {
    Write-Host "   -> Tim thay League of Legends tai: $lolExe" -ForegroundColor Green
}

# -------------------------------------------------------------------------
# 3. KHOA DIRECTX 11 VAO BASEENGINE.INI CUA TFT
# -------------------------------------------------------------------------
if ($tftPath) {
    Write-Host "`n[2/6] Dang cau hinh khoa DirectX 11 trong BaseEngine.ini..." -ForegroundColor Yellow
    $baseEnginePath = Join-Path $tftPath "Engine\Config\BaseEngine.ini"
    
    if (Test-Path $baseEnginePath) {
        # Tao backup neu chua co
        $backupPath = "$baseEnginePath.bak"
        if (-not (Test-Path $backupPath)) {
            Copy-Item $baseEnginePath $backupPath -Force
            Write-Host "   -> Da tao ban sao luu an toan tai: BaseEngine.ini.bak" -ForegroundColor DarkGray
        }

        $content = Get-Content $baseEnginePath -Raw

        # 1. Ep DefaultGraphicsRHI ve DirectX 11
        if ($content -notmatch "DefaultGraphicsRHI=DefaultGraphicsRHI_DX11") {
            $content = $content.Replace("[/Script/WindowsTargetPlatform.WindowsTargetSettings]", "[/Script/WindowsTargetPlatform.WindowsTargetSettings]`r`nDefaultGraphicsRHI=DefaultGraphicsRHI_DX11")
        }

        # 2. Ep r.RHIName=D3D11 trong [SystemSettings]
        if ($content -notmatch "r\.RHIName=D3D11") {
            $content = $content.Replace("[SystemSettings]`r`n", "[SystemSettings]`r`nr.RHIName=D3D11`r`nr.D3D12.Enable=0`r`n")
        }

        Set-Content -Path $baseEnginePath -Value $content -NoNewline
        Write-Host "   -> Da khoa thanh cong DirectX 11 vao BaseEngine.ini!" -ForegroundColor Green
    }
}

# -------------------------------------------------------------------------
# 4. KHOA ENGINE.INI TRONG APPDATA NGUOI DUNG (READ-ONLY)
# -------------------------------------------------------------------------
Write-Host "`n[3/6] Dang khoa Engine.ini (Chong game tu dong ghi de ve DirectX 12)..." -ForegroundColor Yellow
$userEnginePath = "$env:LOCALAPPDATA\TFT\Saved\Config\WindowsClient\Engine.ini"
$parentDir = Split-Path $userEnginePath

if (-not (Test-Path $parentDir)) {
    New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
}

if (Test-Path $userEnginePath) {
    Set-ItemProperty -Path $userEnginePath -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue
}

$engineIniContent = @"
[/Script/WindowsTargetPlatform.WindowsTargetSettings]
DefaultGraphicsRHI=DefaultGraphicsRHI_DX11

[SystemSettings]
r.RHIName=D3D11
r.D3D12.Enable=0

[GameNetDriver StatelessConnectHandlerComponent]
CachedClientID=4
"@

Set-Content -Path $userEnginePath -Value $engineIniContent -Encoding UTF8
Set-ItemProperty -Path $userEnginePath -Name IsReadOnly -Value $true
Write-Host "   -> Da thiet lap va khoa Engine.ini o che do Read-Only!" -ForegroundColor Green

# -------------------------------------------------------------------------
# 5. GAN CO TUONG THICH DISABLE FULLSCREEN OPTIMIZATIONS
# -------------------------------------------------------------------------
Write-Host "`n[4/6] Dang gan co tuong thich chong lag da man hinh..." -ForegroundColor Yellow
$regCompat = "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
if (-not (Test-Path $regCompat)) {
    New-Item -Path $regCompat -Force | Out-Null
}

$binaries = @()
if ($tftPath) {
    $binaries += (Join-Path $tftPath "TFT\Binaries\Win64\TFTClient-Win64-Shipping.exe")
    $binaries += (Join-Path $tftPath "TFTClient.exe")
}
if ($lolExe) {
    $binaries += $lolExe
}

foreach ($bin in $binaries) {
    if (Test-Path $bin) {
        Set-ItemProperty -Path $regCompat -Name $bin -Value "~ DISABLEDXMAXIMIZEDWINDOWEDMODE HIGHDPIAWARE" -Force
        Write-Host "   -> Da gan co tuong thich cho: $(Split-Path $bin -Leaf)" -ForegroundColor Green
    }
}

# -------------------------------------------------------------------------
# 6. THIET LAP TDRDELAY = 30S VA XOA CACHE SHADER AMD
# -------------------------------------------------------------------------
Write-Host "`n[5/6] Kiem tra Registry TdrDelay (Chong ngat card man hinh)..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrDelay" -Value 30 -Type DWord
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "TdrDdiDelay" -Value 30 -Type DWord
    Write-Host "   -> Da cap nhat TdrDelay = 30s va TdrDdiDelay = 30s thanh cong!" -ForegroundColor Green
} else {
    Write-Host "   -> Ban dang chay khong co quyen Administrator. TdrDelay se duoc ap dung khi chay qua file ToiUu_ChoiGame.bat." -ForegroundColor DarkYellow
}

Write-Host "`n[6/6] Dang don sach rac Shader Cache bi loi cua AMD..." -ForegroundColor Yellow
Remove-Item -Path "$env:LOCALAPPDATA\AMD\DxcCache\*" -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:LOCALAPPDATA\AMD\DxCache\*" -Force -ErrorAction SilentlyContinue
Write-Host "   -> Da don dep bo nho dem Shader AMD!" -ForegroundColor Green

Write-Host "`n=========================================================================" -ForegroundColor Cyan
Write-Host "   HOAN TAT TOAN BO CAU HINH! HE THONG DA DUOC TOI UU CHO DTCL" -ForegroundColor Cyan
Write-Host "   Ban co the mo Riot Client va vao game thuong thuc mượt ma!" -ForegroundColor Cyan
Write-Host "=========================================================================`n" -ForegroundColor Cyan
