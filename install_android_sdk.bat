@echo off
echo 🤖 Instalando Android SDK Command Line Tools...

REM Crear directorio para Android SDK
mkdir C:\android-sdk 2>nul
cd C:\android-sdk

echo 📥 Descargando Command Line Tools...
REM Descargar command line tools
curl -o cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip

echo 📦 Extrayendo archivos...
REM Extraer (requiere PowerShell)
powershell -command "Expand-Archive -Path cmdline-tools.zip -DestinationPath . -Force"

REM Crear estructura correcta
mkdir cmdline-tools\latest 2>nul
move cmdline-tools\cmdline-tools\* cmdline-tools\latest\ 2>nul

echo ⚙️ Configurando variables de entorno...
REM Configurar variables de entorno (requiere permisos de administrador)
setx ANDROID_HOME "C:\android-sdk" /M
setx PATH "%PATH%;C:\android-sdk\cmdline-tools\latest\bin;C:\android-sdk\platform-tools" /M

echo 📱 Instalando SDK de Android...
REM Instalar Android SDK
cmdline-tools\latest\bin\sdkmanager.bat "platform-tools" "platforms;android-33" "build-tools;33.0.0"

echo ✅ Android SDK instalado exitosamente!
echo 🔄 Reinicia tu terminal y ejecuta: flutter doctor
pause
