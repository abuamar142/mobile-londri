# PowerShell script for running and building a Flutter application with multiple environments
# Mobile Londri - Flutter Multi-Environment Build Script
# 
# Features:
# - Interactive menu with arrow key navigation
# - Development & Production environments
# - Split APK builds for optimized distribution
# - Automatic APK size calculation
# - Explorer integration for easy file access

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("dev", "prod", "build-dev", "build-prod", "build-prod-split", "help")]
    [string]$Command = ""
)

# Utility function to check prerequisites
function Test-Prerequisites {
    # Check if Flutter is installed
    try {
        $null = flutter --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Flutter not found"
        }
    } catch {
        Write-Host "❌ Flutter is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
        return $false
    }

    # Check if we're in a Flutter project
    if (-not (Test-Path "pubspec.yaml")) {
        Write-Host "❌ Not in a Flutter project directory" -ForegroundColor Red
        Write-Host "Please run this script from the Flutter project root" -ForegroundColor Yellow
        return $false
    }

    return $true
}

# Interactive menu function
function Show-Menu {
    $menuItems = @(
        @{ Key = "dev"; Display = "🚀 Run Development Mode"; Description = "Run app with debug features enabled" },
        @{ Key = "prod"; Display = "🏭 Run Production Mode"; Description = "Run app in optimized release mode" },
        @{ Key = "build-dev"; Display = "🏗️  Build Development APK"; Description = "Create debug APK for testing" },
        @{ Key = "build-prod"; Display = "📦 Build Production APK"; Description = "Create universal release APK" },
        @{ Key = "build-prod-split"; Display = "🎯 Build Split APKs"; Description = "Create optimized APKs per architecture" },
        @{ Key = "help"; Display = "❓ Show Help"; Description = "Display detailed command information" },
        @{ Key = "exit"; Display = "🚪 Exit"; Description = "Close the script" }
    )
    
    $selectedIndex = 0
    
    do {
        Clear-Host
        Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║               🚀 Mobile Londri Build Menu               ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Use ↑↓ arrow keys to navigate, Enter to select, Esc to exit" -ForegroundColor Yellow
        Write-Host ""
        
        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            if ($i -eq $selectedIndex) {
                Write-Host "  ▶ " -ForegroundColor Green -NoNewline
                Write-Host $menuItems[$i].Display -ForegroundColor White -BackgroundColor DarkBlue
                Write-Host "    " -NoNewline
                Write-Host $menuItems[$i].Description -ForegroundColor Gray
            } else {
                Write-Host "    " -NoNewline
                Write-Host $menuItems[$i].Display -ForegroundColor White
                Write-Host "    " -NoNewline
                Write-Host $menuItems[$i].Description -ForegroundColor DarkGray
            }
            Write-Host ""
        }
        
        Write-Host ""
        Write-Host "Current Selection: " -ForegroundColor Cyan -NoNewline
        Write-Host $menuItems[$selectedIndex].Display -ForegroundColor Yellow
        
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        
        switch ($key.VirtualKeyCode) {
            38 { # Up arrow
                $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $menuItems.Count - 1 }
            }
            40 { # Down arrow  
                $selectedIndex = if ($selectedIndex -lt ($menuItems.Count - 1)) { $selectedIndex + 1 } else { 0 }
            }
            13 { # Enter
                Clear-Host
                return $menuItems[$selectedIndex].Key
            }
            27 { # Escape
                Clear-Host
                Write-Host "👋 Goodbye!" -ForegroundColor Green
                exit 0
            }
        }
    } while ($true)
}

function Show-Help {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                🚀 Mobile Londri Build Scripts             ║" -ForegroundColor Green  
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Available Commands:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  🚀 dev              " -NoNewline -ForegroundColor White
    Write-Host "- Run app in development mode" -ForegroundColor Gray
    Write-Host "  🏭 prod             " -NoNewline -ForegroundColor White  
    Write-Host "- Run app in production mode" -ForegroundColor Gray
    Write-Host "  🏗️  build-dev        " -NoNewline -ForegroundColor White
    Write-Host "- Build development APK" -ForegroundColor Gray
    Write-Host "  📦 build-prod       " -NoNewline -ForegroundColor White
    Write-Host "- Build production APK (universal)" -ForegroundColor Gray
    Write-Host "  🎯 build-prod-split " -NoNewline -ForegroundColor White
    Write-Host "- Build production APK split per ABI" -ForegroundColor Gray
    Write-Host "  ❓ help             " -NoNewline -ForegroundColor White
    Write-Host "- Show this help message" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🎮 Interactive Mode:" -ForegroundColor Yellow
    Write-Host "  Simply run: " -NoNewline -ForegroundColor Gray
    Write-Host ".\run_app.ps1" -ForegroundColor Cyan
    Write-Host "  Then use ↑↓ arrows to navigate and Enter to select" -ForegroundColor Gray
    Write-Host ""
    Write-Host "⌨️  Command Line Mode:" -ForegroundColor Yellow
    Write-Host "  .\run_app.ps1 dev              " -ForegroundColor Cyan
    Write-Host "  .\run_app.ps1 prod             " -ForegroundColor Cyan
    Write-Host "  .\run_app.ps1 build-dev        " -ForegroundColor Cyan
    Write-Host "  .\run_app.ps1 build-prod       " -ForegroundColor Cyan
    Write-Host "  .\run_app.ps1 build-prod-split " -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📱 Split APK Info:" -ForegroundColor Yellow
    Write-Host "  • Creates separate APKs for arm64-v8a, armeabi-v7a, x86_64" -ForegroundColor Gray
    Write-Host "  • Smaller file sizes for distribution (~50% reduction)" -ForegroundColor Gray
    Write-Host "  • Better performance on specific architectures" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Press any key to return to menu..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    
    # Return to interactive menu
    $selectedCommand = Show-Menu
    switch ($selectedCommand) {
        "dev" { Run-Dev }
        "prod" { Run-Prod }
        "build-dev" { Build-Dev }
        "build-prod" { Build-Prod }
        "build-prod-split" { Build-Prod-Split }
        "exit" { 
            Write-Host "👋 Goodbye!" -ForegroundColor Green
            exit 0 
        }
    }
}

# Helper function to return to menu
function Return-ToMenu {
    Write-Host ""
    Write-Host "Press any key to return to menu..." -ForegroundColor Cyan
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $selectedCommand = Show-Menu
    switch ($selectedCommand) {
        "dev" { Run-Dev }
        "prod" { Run-Prod }
        "build-dev" { Build-Dev }
        "build-prod" { Build-Prod }
        "build-prod-split" { Build-Prod-Split }
        "help" { Show-Help }
        "exit" { 
            Write-Host "👋 Goodbye!" -ForegroundColor Green
            exit 0 
        }
    }
}

function Run-Dev {
    Clear-Host
    Write-Host "🚀 Starting Mobile Londri in DEVELOPMENT mode..." -ForegroundColor Green
    Write-Host "Environment: Development" -ForegroundColor Yellow
    Write-Host "Debug Mode: Enabled" -ForegroundColor Yellow
    Write-Host "App Name: Londri (Dev)" -ForegroundColor Yellow
    Write-Host "Target: lib/main_dev.dart" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        Return-ToMenu
        return
    }
    
    # Check for devices
    Write-Host "🔍 Checking available devices..." -ForegroundColor Cyan
    flutter devices
    Write-Host ""
    
    flutter run -t lib/main_dev.dart --flavor dev
    
    Return-ToMenu
}

function Run-Prod {
    Clear-Host
    Write-Host "🚀 Starting Mobile Londri in PRODUCTION mode..." -ForegroundColor Green
    Write-Host "Environment: Production" -ForegroundColor Yellow
    Write-Host "Debug Mode: Disabled" -ForegroundColor Yellow
    Write-Host "App Name: Londri" -ForegroundColor Yellow
    Write-Host "Target: lib/main_prod.dart" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        Return-ToMenu
        return
    }
    
    # Check for devices
    Write-Host "🔍 Checking available devices..." -ForegroundColor Cyan
    flutter devices
    Write-Host ""
    
    flutter run -t lib/main_prod.dart --flavor prod --release
    
    Return-ToMenu
}

function Build-Dev {
    Clear-Host
    Write-Host "🏗️  Building Mobile Londri for DEVELOPMENT..." -ForegroundColor Green
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        Return-ToMenu
        return
    }
    
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Cyan
    flutter clean | Out-Null
    flutter pub get | Out-Null
    
    Write-Host "⚙️  Building APK..." -ForegroundColor Cyan
    flutter build apk -t lib/main_dev.dart --flavor dev --debug
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Development APK built successfully!" -ForegroundColor Green
        Write-Host "📍 Location: build/app/outputs/flutter-apk/app-dev-debug.apk" -ForegroundColor Cyan
        
        # Show APK size
        $apkPath = "build/app/outputs/flutter-apk/app-dev-debug.apk"
        if (Test-Path $apkPath) {
            $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Host "💾 Size: $size MB" -ForegroundColor Gray
            Write-Host "🚀 Opening APK folder..." -ForegroundColor Green
            explorer "build\app\outputs\flutter-apk"
        }
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
        Write-Host "💡 Try running: flutter doctor" -ForegroundColor Yellow
    }
    
    Return-ToMenu
}

function Build-Prod {
    Write-Host "🏗️  Building Mobile Londri for PRODUCTION..." -ForegroundColor Green
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        return
    }
    
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Cyan
    flutter clean | Out-Null
    flutter pub get | Out-Null
    
    Write-Host "⚙️  Building release APK..." -ForegroundColor Cyan
    flutter build apk -t lib/main_prod.dart --flavor prod --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Production APK built successfully!" -ForegroundColor Green
        Write-Host "📍 Location: build/app/outputs/flutter-apk/app-prod-release.apk" -ForegroundColor Cyan
          # Show APK size
        $apkPath = "build/app/outputs/flutter-apk/app-prod-release.apk"
        if (Test-Path $apkPath) {
            $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
            Write-Host "💾 Size: $size MB" -ForegroundColor Gray
            Write-Host "🚀 Opening APK folder..." -ForegroundColor Green
            explorer "build\app\outputs\flutter-apk"
        }
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
        Write-Host "💡 Try running: flutter doctor" -ForegroundColor Yellow
    }
}

function Build-Prod-Split {
    Write-Host "🏗️  Building Mobile Londri for PRODUCTION (Split per ABI)..." -ForegroundColor Green
    Write-Host "📱 This will create separate APKs for different architectures" -ForegroundColor Yellow
    Write-Host ""
    
    if (-not (Test-Prerequisites)) {
        return
    }
    
    Write-Host "🧹 Cleaning previous builds..." -ForegroundColor Cyan
    flutter clean | Out-Null
    flutter pub get | Out-Null
    
    Write-Host "⚙️  Building split APKs..." -ForegroundColor Cyan
    # Build split APKs
    flutter build apk -t lib/main_prod.dart --flavor prod --release --split-per-abi
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Production APKs built successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📍 APK Locations:" -ForegroundColor Cyan
        
        # List all generated APKs with their sizes
        $apkDir = "build/app/outputs/flutter-apk"
        $apkFiles = @(
            "app-arm64-v8a-prod-release.apk",
            "app-armeabi-v7a-prod-release.apk", 
            "app-x86_64-prod-release.apk"
        )
        
        foreach ($apkFile in $apkFiles) {
            $apkPath = Join-Path $apkDir $apkFile
            if (Test-Path $apkPath) {
                $size = [math]::Round((Get-Item $apkPath).Length / 1MB, 2)
                $arch = $apkFile -replace "app-", "" -replace "-prod-release.apk", ""
                Write-Host "  📱 $arch`: $apkFile ($size MB)" -ForegroundColor White
            }
        }
        
        Write-Host ""
        Write-Host "💡 Architecture Guide:" -ForegroundColor Yellow
        Write-Host "  arm64-v8a    - Modern 64-bit ARM (most new devices)" -ForegroundColor Gray
        Write-Host "  armeabi-v7a  - 32-bit ARM (older devices)" -ForegroundColor Gray
        Write-Host "  x86_64       - 64-bit Intel (emulators, some tablets)" -ForegroundColor Gray
        Write-Host ""
        Write-Host "🚀 Opening APK folder..." -ForegroundColor Green
        explorer $apkDir
        
    } else {
        Write-Host "❌ Build failed!" -ForegroundColor Red
    }
}

# Execute commands
if ($Command -eq "") {
    # Interactive mode
    $selectedCommand = Show-Menu
    $Command = $selectedCommand
}

switch ($Command) {
    "dev" { Run-Dev }
    "prod" { Run-Prod }
    "build-dev" { Build-Dev }
    "build-prod" { Build-Prod }
    "build-prod-split" { Build-Prod-Split }
    "help" { Show-Help }
    "exit" { 
        Write-Host "👋 Goodbye!" -ForegroundColor Green
        exit 0 
    }
    default { Show-Help }
}
