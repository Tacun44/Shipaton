# Script para configurar Android SDK automáticamente
Write-Host "🤖 Configurando Android SDK..." -ForegroundColor Green

# Ruta típica de Android SDK
$androidSdkPath = "$env:LOCALAPPDATA\Android\Sdk"

# Verificar si existe
if (Test-Path $androidSdkPath) {
    Write-Host "✅ Android SDK encontrado en: $androidSdkPath" -ForegroundColor Green
    
    # Configurar variables de entorno para la sesión actual
    $env:ANDROID_HOME = $androidSdkPath
    $env:PATH += ";$androidSdkPath\platform-tools;$androidSdkPath\cmdline-tools\latest\bin"
    
    Write-Host "🔧 Variables de entorno configuradas para esta sesión" -ForegroundColor Yellow
    Write-Host "ANDROID_HOME = $env:ANDROID_HOME" -ForegroundColor Cyan
    
    # Verificar Flutter doctor
    Write-Host "🔍 Verificando configuración Flutter..." -ForegroundColor Blue
    flutter doctor
    
    Write-Host "🎯 Listo para generar APK!" -ForegroundColor Green
    Write-Host "Ejecuta: flutter build apk --debug" -ForegroundColor Yellow
    
} else {
    Write-Host "❌ Android SDK no encontrado en $androidSdkPath" -ForegroundColor Red
    Write-Host "📥 Por favor instala Android Studio primero" -ForegroundColor Yellow
    Write-Host "🔗 https://developer.android.com/studio" -ForegroundColor Cyan
}
