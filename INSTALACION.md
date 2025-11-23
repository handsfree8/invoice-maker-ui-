# 📱 Guía Rápida de Instalación en tu iPhone

## 🎯 Opción Más Fácil: Instalación Directa desde Xcode

### Requisitos Previos
- ✅ Mac con Xcode instalado
- ✅ Cable USB-C o Lightning
- ✅ iPhone con iOS 15 o superior
- ✅ Apple ID (gratuito)

### Paso a Paso (5 minutos)

#### 1. Preparar Xcode
```bash
# Abrir el proyecto
cd /Users/roselegacyhomesolutions/Documents/GitHub/invoice-maker-ui-
open "Invoice Maker.xcodeproj"
```

#### 2. Configurar Apple ID
1. En Xcode: **Xcode → Settings → Accounts**
2. Click en **+** → **Apple ID**
3. Ingresa tu Apple ID y contraseña
4. ✅ Listo

#### 3. Conectar tu iPhone
1. Conecta tu iPhone al Mac con el cable
2. En el iPhone: **Settings → General → VPN & Device Management**
3. Confía en tu Mac si aparece el mensaje

#### 4. Configurar Signing
1. En Xcode, selecciona el proyecto "Invoice Maker"
2. Click en la pestaña **Signing & Capabilities**
3. En **Team**, selecciona tu Apple ID (Personal Team)
4. ✅ Debe aparecer "Signing Certificate: Apple Development"

#### 5. Seleccionar tu iPhone
1. En la barra superior de Xcode, busca el menú de dispositivos
2. Click y selecciona tu iPhone (debe aparecer con su nombre)
3. NO selecciones el simulador

#### 6. Compilar e Instalar
1. Click en el botón **Play** (▶️) o presiona `Cmd + R`
2. Espera a que compile (1-2 minutos la primera vez)
3. ✅ La app se instalará automáticamente en tu iPhone

#### 7. Confiar en el Desarrollador (Primera vez)
1. En tu iPhone: **Settings → General → VPN & Device Management**
2. Busca tu Apple ID bajo "Developer App"
3. Click → **Trust "[Tu Apple ID]"**
4. Confirma **Trust**

#### 8. ¡Listo! 🎉
Abre "Invoice Maker" en tu iPhone y usa:
- **Usuario**: `admin`
- **Contraseña**: `RoseLegacy2025`

---

## 🔄 Actualizaciones Futuras

Cada vez que hagas cambios:
1. Conecta tu iPhone
2. En Xcode presiona `Cmd + R`
3. La app se actualiza automáticamente

---

## ⚠️ Notas Importantes

### Certificado de Desarrollo
- **Válido por**: 7 días (Apple ID gratis)
- **Qué pasa después**: La app dejará de abrir
- **Solución**: Reconectar el iPhone y volver a instalar (toma 30 segundos)

### Para Uso Permanente (Recomendado)
Si quieres que la app funcione sin tener que reinstalarla cada semana:

**Opción 1: Apple Developer Program** ($99/año)
- Certificados válidos por 1 año
- Permite TestFlight
- Puedes publicar en App Store

**Opción 2: Ad-Hoc Distribution** (Necesita Developer Program)
- La app no expira
- Instalación más simple
- Hasta 100 dispositivos

---

## 🆘 Problemas Comunes

### "Untrusted Developer"
**Problema**: Al abrir la app aparece mensaje de desarrollador no confiable
**Solución**: Settings → General → VPN & Device Management → Trust

### "Could not launch app"
**Problema**: La app no inicia desde Xcode
**Solución**: 
1. En el iPhone, cierra la app si está abierta
2. En Xcode, limpia el build: `Product → Clean Build Folder`
3. Intenta de nuevo: `Cmd + R`

### "No code signing identities found"
**Problema**: Xcode no encuentra certificado
**Solución**:
1. Xcode → Settings → Accounts
2. Verifica que tu Apple ID esté agregado
3. Click en tu Apple ID → **Manage Certificates**
4. Si no hay ninguno, click **+** → **Apple Development**

### "Profile doesn't match"
**Problema**: Error de provisioning profile
**Solución**:
1. Selecciona el proyecto en Xcode
2. En **Signing & Capabilities**
3. ✅ Activa "Automatically manage signing"
4. Selecciona tu Team

### El iPhone no aparece en Xcode
**Problema**: No puedo seleccionar mi iPhone
**Solución**:
1. Desconecta y reconecta el cable
2. Desbloquea el iPhone
3. En el iPhone: "Trust This Computer"
4. En Xcode: **Window → Devices and Simulators**
5. Verifica que tu iPhone aparezca conectado

---

## 📊 Comparación de Opciones

| Método | Duración | Costo | Complejidad | Recomendado |
|--------|----------|-------|-------------|-------------|
| **Xcode Directo** | 7 días | Gratis | ⭐ Fácil | ✅ Para probar |
| **TestFlight** | 90 días | $99/año | ⭐⭐ Media | ✅ Para uso regular |
| **Ad-Hoc** | 1 año | $99/año | ⭐⭐⭐ Alta | Para distribución |
| **App Store** | Permanente | $99/año | ⭐⭐⭐⭐ Muy alta | Para público |

---

## 🎯 Mi Recomendación Personal

Para **uso personal en tu iPhone de Rose Legacy**:

### Corto Plazo (Próximos días)
👉 **Usa Xcode Directo**
- Es gratis
- Funciona perfectamente
- Reinstalar cada semana toma 30 segundos

### Mediano Plazo (Próximos meses)
👉 **Paga el Apple Developer Program** ($99/año)
- Certificados válidos 1 año
- TestFlight para probar con tu equipo
- Posibilidad de publicar en App Store después

### Beneficios del Developer Program
1. ✅ Instala la app una vez, funciona todo el año
2. ✅ Comparte con tu equipo vía TestFlight
3. ✅ Actualizaciones automáticas para todos
4. ✅ Estadísticas de uso
5. ✅ Beta testing profesional

---

## 📞 ¿Necesitas Ayuda?

**Opción 1**: Llámame mientras instalas
- Puedo guiarte paso a paso por teléfono
- Tardaremos 5 minutos juntos

**Opción 2**: TeamViewer / AnyDesk
- Puedo conectarme remotamente a tu Mac
- Lo hago todo por ti

**Opción 3**: Presencial
- Si estás cerca, puedo ir y configurarlo

---

## ✅ Checklist de Instalación

Antes de empezar, verifica:
- [ ] Tengo un Mac con Xcode instalado
- [ ] Tengo mi iPhone y el cable
- [ ] Tengo mi Apple ID y contraseña
- [ ] El proyecto está clonado en mi Mac
- [ ] He leído esta guía completa

Durante la instalación:
- [ ] Apple ID agregado en Xcode
- [ ] iPhone conectado y confiado
- [ ] Team seleccionado en Signing
- [ ] iPhone seleccionado como destino
- [ ] Build exitoso (sin errores rojos)
- [ ] Desarrollador confiado en el iPhone

Después de instalar:
- [ ] La app abre correctamente
- [ ] Puedo hacer login
- [ ] Puedo crear una factura de prueba
- [ ] Puedo exportar un PDF
- [ ] He creado un backup manual

---

**¡Éxito! 🎉 Tu app está lista para usar.**

Cualquier duda, contáctame. Estoy aquí para ayudarte.

---

*Última actualización: 19 de Noviembre, 2025*
