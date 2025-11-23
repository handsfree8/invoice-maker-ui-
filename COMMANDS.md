# 🛠️ Comandos Útiles - Invoice Maker

## 📱 Compilación y Testing

### Compilar para iPhone Simulador
```bash
xcodebuild -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

### Compilar para tu iPhone (Conectado)
```bash
xcodebuild -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  -destination 'generic/platform=iOS' \
  build
```

### Limpiar Build
```bash
xcodebuild -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  clean
```

### Ver Todos los Simuladores Disponibles
```bash
xcrun simctl list devices
```

---

## 📦 Archiving y Distribution

### Crear Archive para TestFlight/App Store
```bash
xcodebuild -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  -archivePath "./build/InvoiceMaker.xcarchive" \
  archive
```

### Export para Ad-Hoc
```bash
xcodebuild -exportArchive \
  -archivePath "./build/InvoiceMaker.xcarchive" \
  -exportPath "./build/AdHoc" \
  -exportOptionsPlist "./ExportOptions.plist"
```

---

## 🔍 Análisis y Debugging

### Ver Warnings y Errors
```bash
xcodebuild -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build 2>&1 | grep -E "(warning|error)"
```

### Contar Líneas de Código
```bash
find "Invoice Maker" -name "*.swift" | xargs wc -l
```

### Ver Tamaño del Proyecto
```bash
du -sh "Invoice Maker.xcodeproj"
du -sh "Invoice Maker"
```

---

## 📂 Gestión de Archivos

### Listar Archivos Swift
```bash
find "Invoice Maker" -name "*.swift" -type f
```

### Buscar en el Código
```bash
grep -r "TODO" "Invoice Maker" --include="*.swift"
grep -r "FIXME" "Invoice Maker" --include="*.swift"
```

### Ver Estructura del Proyecto
```bash
tree "Invoice Maker" -L 2 -I "*.xcassets|*.xcodeproj"
```

---

## 🗑️ Limpieza

### Limpiar Derived Data
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/Invoice_Maker-*
```

### Limpiar Archives Viejos
```bash
rm -rf ~/Library/Developer/Xcode/Archives/*/Invoice\ Maker*
```

### Limpiar Build Folder Local
```bash
rm -rf ./build
```

---

## 📊 Estadísticas del Proyecto

### Contar Archivos Swift
```bash
find "Invoice Maker" -name "*.swift" | wc -l
```

### Total de Líneas de Código
```bash
find "Invoice Maker" -name "*.swift" -exec cat {} \; | wc -l
```

### Archivos Más Grandes
```bash
find "Invoice Maker" -name "*.swift" -exec wc -l {} \; | sort -rn | head -10
```

---

## 🔐 Keychain y Simulador

### Resetear Simulador (Borra todos los datos)
```bash
xcrun simctl erase all
```

### Listar Apps Instaladas en Simulador
```bash
xcrun simctl listapps booted
```

### Instalar App en Simulador Específico
```bash
xcrun simctl install <DEVICE_ID> ./build/InvoiceMaker.app
```

---

## 🚀 Atajos de Xcode desde Terminal

### Abrir Proyecto
```bash
open "Invoice Maker.xcodeproj"
```

### Abrir en Xcode Específico
```bash
open -a "Xcode" "Invoice Maker.xcodeproj"
```

### Ver Versión de Xcode
```bash
xcodebuild -version
xcrun --show-sdk-version
```

---

## 📱 Gestión de Dispositivos

### Listar Dispositivos Conectados
```bash
xcrun xctrace list devices
```

### Ver Info del Device
```bash
ideviceinfo
```

### Instalar en Device Conectado (necesita ios-deploy)
```bash
ios-deploy --bundle ./build/InvoiceMaker.app
```

---

## 🧪 Testing

### Correr Unit Tests
```bash
xcodebuild test \
  -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Ver Coverage de Tests
```bash
xcodebuild test \
  -project "Invoice Maker.xcodeproj" \
  -scheme "Invoice Maker" \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -enableCodeCoverage YES
```

---

## 📝 Documentación

### Generar Documentación (con Jazzy)
```bash
jazzy \
  --clean \
  --author "Rose Legacy Home Solutions" \
  --module "Invoice Maker" \
  --output docs/ \
  --theme fullwidth
```

---

## 🔄 Git Útiles

### Ver Estado
```bash
git status
```

### Commit de Cambios
```bash
git add .
git commit -m "feat: implement backup and settings features"
```

### Push a GitHub
```bash
git push origin main
```

### Ver Historial
```bash
git log --oneline --graph --all --decorate
```

### Crear Tag de Versión
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

---

## 🎨 Generación de Assets

### Ver Assets en el Proyecto
```bash
find "Invoice Maker/Assets.xcassets" -type f
```

### Generar Iconos de App (necesita imagemagick)
```bash
# Desde una imagen de 1024x1024
convert original-icon.png -resize 1024x1024 appicon-1024.png
```

---

## 📦 Dependencias

### Listar SPM Dependencies
```bash
swift package show-dependencies
```

### Actualizar Dependencies
```bash
swift package update
```

---

## 🎯 Shortcuts Personalizados

### Build Rápido
```bash
alias build-invoice="xcodebuild -project 'Invoice Maker.xcodeproj' -scheme 'Invoice Maker' -destination 'platform=iOS Simulator,name=iPhone 16' build"
```

### Clean + Build
```bash
alias clean-build="xcodebuild clean && xcodebuild build"
```

### Abrir Proyecto
```bash
alias invoice="cd ~/Documents/GitHub/invoice-maker-ui- && open 'Invoice Maker.xcodeproj'"
```

Agregar a tu `~/.zshrc` o `~/.bash_profile`:
```bash
# Invoice Maker Shortcuts
export INVOICE_PATH="~/Documents/GitHub/invoice-maker-ui-"
alias invoice-open="cd $INVOICE_PATH && open 'Invoice Maker.xcodeproj'"
alias invoice-build="cd $INVOICE_PATH && xcodebuild -project 'Invoice Maker.xcodeproj' -scheme 'Invoice Maker' build"
alias invoice-clean="cd $INVOICE_PATH && rm -rf DerivedData"
```

---

## 🚀 One-Liners Útiles

### Build y correr en iPhone conectado
```bash
xcodebuild -project "Invoice Maker.xcodeproj" -scheme "Invoice Maker" -destination 'generic/platform=iOS' build && ios-deploy --bundle ./build/InvoiceMaker.app
```

### Contar TODOs en el proyecto
```bash
grep -r "TODO" "Invoice Maker" --include="*.swift" | wc -l
```

### Ver último build exitoso
```bash
ls -lt ~/Library/Developer/Xcode/DerivedData/Invoice_Maker-*/Build/Products/Debug-iphonesimulator/ | head -5
```

---

## 📱 Comandos de Producción

### Verificar Bundle ID
```bash
/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "Invoice Maker/Info.plist"
```

### Ver Versión
```bash
/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "Invoice Maker/Info.plist"
```

### Ver Build Number
```bash
/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "Invoice Maker/Info.plist"
```

---

## 🔧 Troubleshooting

### Cuando Xcode se porta raro
```bash
# Paso 1: Cerrar Xcode
killall Xcode

# Paso 2: Limpiar todo
rm -rf ~/Library/Developer/Xcode/DerivedData/Invoice_Maker-*
rm -rf ~/Library/Caches/com.apple.dt.Xcode

# Paso 3: Abrir de nuevo
open "Invoice Maker.xcodeproj"
```

### Reset Complete del Simulador
```bash
xcrun simctl shutdown all
xcrun simctl erase all
```

---

## 📊 Reportes y Analytics

### Build Time
```bash
time xcodebuild -project "Invoice Maker.xcodeproj" -scheme "Invoice Maker" build
```

### Tamaño del .app
```bash
du -sh ~/Library/Developer/Xcode/DerivedData/Invoice_Maker-*/Build/Products/Debug-iphonesimulator/Invoice\ Maker.app
```

---

## 🎓 Tips y Trucos

### Ver logs del simulador en tiempo real
```bash
xcrun simctl spawn booted log stream --level debug
```

### Capturar screenshot del simulador
```bash
xcrun simctl io booted screenshot screenshot.png
```

### Grabar video del simulador
```bash
xcrun simctl io booted recordVideo --codec=h264 demo.mp4
# Presiona Ctrl+C para parar
```

---

## 🆘 Comandos de Emergencia

### App no instala
```bash
# Borrar app del simulador
xcrun simctl uninstall booted RoseLegacy.Invoice-Maker
# Reinstalar
xcodebuild -project "Invoice Maker.xcodeproj" -scheme "Invoice Maker" clean build
```

### Keychain issues
```bash
security delete-generic-password -s "com.roselegacy.invoicemaker"
```

---

**Guarda este archivo como referencia rápida!** 🚀

Cualquier comando que uses frecuentemente, agrégalo aquí.

---

*Última actualización: 19 de Noviembre, 2025*
