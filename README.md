# 🚢 Shipaton - Flutter + Supabase + Biometría

Una aplicación Flutter moderna con autenticación biométrica y backend Supabase.

## ✨ Características

- 🔐 **Autenticación completa**: Login, registro y gestión de usuarios
- 👆 **Biometría**: Huella dactilar y Face ID para acceso rápido
- 🛡️ **Seguridad**: Row Level Security (RLS) en Supabase
- 📱 **Multiplataforma**: Android, iOS, Web, Windows
- 🎨 **UI Moderna**: Material Design 3

## 🚀 Generar APK con GitHub Actions

### Paso 1: Subir a GitHub
```bash
git init
git add .
git commit -m "🎉 Inicial: App con autenticación biométrica"
git branch -M main
git remote add origin https://github.com/tu-usuario/shipaton.git
git push -u origin main
```

### Paso 2: Generar APK
1. Ve a tu repositorio en GitHub
2. Clic en **Actions** → **📱 Build Android APK**
3. Clic en **Run workflow** → Selecciona **debug** → **Run workflow**
4. Espera 3-5 minutos
5. Descarga el APK desde **Artifacts**

### Paso 3: Instalar en Android
1. Transfiere el APK a tu teléfono
2. Habilita **Fuentes desconocidas** en Configuración
3. Instala el APK
4. ¡Prueba la huella dactilar!

## 🛠️ Desarrollo Local

### Requisitos
- Flutter SDK 3.9+
- Dart 3.0+
- Android Studio (para APK local)

### Comandos
```bash
# Instalar dependencias
flutter pub get

# Ejecutar en web
flutter run -d edge

# Generar APK (requiere Android SDK)
flutter build apk --debug
```

## 🔧 Configuración Supabase

La app está configurada con:
- **URL**: `https://tycabutsaykxvuhfctpg.supabase.co`
- **Tablas**: `profiles` con RLS habilitado
- **Auth**: Email/contraseña + biometría

## 📱 Funcionalidades Biométricas

- ✅ **Detección automática** de huella/Face ID
- ✅ **Configuración opcional** después del primer login
- ✅ **Almacenamiento seguro** de credenciales
- ✅ **Fallback** a PIN/patrón
- ✅ **Soporte multiplataforma**

## 🧪 Testing

```bash
# Tests unitarios
flutter test

# Análisis de código
flutter analyze
```

## 📦 Build Commands

```bash
# Debug APK (para pruebas)
flutter build apk --debug

# Release APK (para distribución)
flutter build apk --release

# Bundle AAB (para Play Store)
flutter build appbundle --release
```

## 🔐 Credenciales de Prueba

- **Email**: whither82@gmail.com
- **Contraseña**: [tu contraseña]
- **Usuario**: Emmanuel

## 🎯 Flujo de Autenticación

1. **Primera vez**: Login con email/contraseña
2. **Configuración**: Se ofrece configurar biometría
3. **Siguientes veces**: Login con huella/Face ID
4. **Seguridad**: Credenciales cifradas localmente