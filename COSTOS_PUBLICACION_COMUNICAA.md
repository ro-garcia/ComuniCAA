# Evaluacion de Costos para Publicar ComuniCAA en Web y Tiendas Moviles

## 1. Alcance de la evaluacion

Esta evaluacion se basa en el estado actual del proyecto ComuniCAA: una aplicacion Flutter con soporte para Android, iOS y Web, assets locales de pictogramas, audios pregrabados y reproduccion mediante Text-to-Speech (TTS). Actualmente el proyecto funciona como prototipo frontend, sin backend, autenticacion, base de datos remota ni pasarela de pagos integrada.

Por esta razon, los costos iniciales pueden mantenerse bajos. Los costos aumentarian si se agregan funciones premium reales como cuentas de usuario, sincronizacion en la nube, suscripciones, analitica avanzada, panel administrativo o almacenamiento remoto.

## 2. Costos para publicar en Web

ComuniCAA puede publicarse como aplicacion web estatica porque Flutter genera archivos HTML, JavaScript y assets que pueden alojarse en servicios como GitHub Pages o Firebase Hosting.

### Opcion recomendada inicial: GitHub Pages

| Concepto | Costo estimado | Frecuencia | Observacion |
| --- | ---: | --- | --- |
| GitHub Pages | USD 0 | Mensual/anual | Adecuado para prototipo publico o demo web. |
| Certificado SSL | USD 0 | Incluido | GitHub Pages permite HTTPS. |
| Dominio personalizado | USD 10 a 20 | Anual | Opcional. Ejemplo: `comunicaa.app` o similar. |
| Configuracion inicial | USD 0 si lo hace el grupo | Unica vez | Requiere compilar Flutter Web y configurar Pages. |

### Limitaciones de GitHub Pages

GitHub Pages es adecuado para ComuniCAA mientras la aplicacion sea estatica. Sus limites oficiales incluyen sitio publicado de hasta 1 GB y limite blando de ancho de banda de 100 GB al mes. Para un prototipo o proyecto academico, estos limites suelen ser suficientes.

### Alternativa: Firebase Hosting

| Concepto | Costo estimado | Frecuencia | Observacion |
| --- | ---: | --- | --- |
| Firebase Hosting Spark | USD 0 | Mensual | Incluye cuota gratuita. |
| Firebase Hosting Blaze | Variable | Mensual | Pago por uso si se superan limites gratuitos. |
| Dominio personalizado | USD 10 a 20 | Anual | Opcional. |

Firebase es conveniente si despues se agregan autenticacion, base de datos, almacenamiento de imagenes o analitica.

## 3. Costos para publicar en Google Play Store

Para distribuir ComuniCAA oficialmente en Android mediante Google Play se requiere una cuenta de desarrollador.

| Concepto | Costo estimado | Frecuencia | Observacion |
| --- | ---: | --- | --- |
| Cuenta Google Play Console | USD 25 | Pago unico | Requerida para distribucion completa. |
| Publicacion de la app | USD 0 adicional | Por app | No se paga por cada app publicada. |
| Pruebas cerradas para cuenta personal nueva | USD 0 | Requisito de proceso | Cuentas personales nuevas deben realizar prueba cerrada con 12 testers por 14 dias. |
| Capturas, iconos y ficha de tienda | USD 0 si lo hace el grupo | Unica vez | Se necesitan textos, imagenes y politicas. |
| Politica de privacidad | USD 0 a 20 | Anual | Puede alojarse gratis en GitHub Pages; dominio opcional. |

### Consideraciones para Google Play

- Si la app sera gratuita, no hay comision por descarga.
- Si se venden funciones digitales premium o suscripciones dentro de la app, Google Play aplica tarifas de servicio segun tipo de transaccion, region y programa.
- Para cuentas personales nuevas, Google exige una prueba cerrada antes de habilitar produccion.
- Se debe completar la ficha de Play Store, clasificacion de contenido, declaracion de datos y pruebas.

## 4. Costos para publicar en Apple App Store

Para distribuir ComuniCAA en iPhone o iPad mediante App Store se requiere inscripcion al Apple Developer Program.

| Concepto | Costo estimado | Frecuencia | Observacion |
| --- | ---: | --- | --- |
| Apple Developer Program | USD 99 | Anual | Obligatorio para publicar en App Store y usar TestFlight. |
| Publicacion de la app | USD 0 adicional | Por app | Incluido con la membresia. |
| Mac con Xcode | USD 0 si ya se tiene | Segun caso | Flutter requiere macOS y Xcode para compilar/publicar iOS. |
| Mac si no se posee equipo | USD 599 o mas | Unica vez | Puede usarse Mac propio, prestado, alquilado o CI con macOS. |
| Capturas para App Store | USD 0 si lo hace el grupo | Unica vez | Apple requiere capturas por plataforma/dispositivo. |
| Politica de privacidad | USD 0 a 20 | Anual | Apple exige URL de politica de privacidad para apps iOS. |

### Consideraciones para App Store

- La membresia Apple es anual; si no se renueva, se pierde capacidad de mantener la app publicada/actualizada.
- Para compilar iOS se necesita macOS con Xcode.
- Apple exige informacion de privacidad, capturas, metadatos, iconos y revision de la app.
- Si ComuniCAA vende funciones digitales premium, Apple puede aplicar comision. En el App Store Small Business Program, desarrolladores elegibles pueden acceder a comision reducida del 15%; la tarifa estandar puede ser mayor.

## 5. Costos de preparacion tecnica del proyecto

Aunque el proyecto ya existe, antes de publicarlo se recomienda preparar una version de produccion.

| Actividad | Costo si lo hace el grupo | Costo si se contrata | Observacion |
| --- | ---: | ---: | --- |
| Compilar Flutter Web y configurar GitHub Pages | USD 0 | USD 50 a 150 | Trabajo corto si no hay errores. |
| Generar Android App Bundle firmado | USD 0 | USD 100 a 300 | Requiere keystore y configuracion de version. |
| Preparar publicacion en Play Store | USD 25 oficiales | USD 150 a 500 | Incluye ficha, pruebas, politicas y subida. |
| Preparar build iOS y TestFlight | USD 99 oficiales | USD 250 a 800 | Requiere Mac, Xcode y cuenta Apple. |
| Preparar capturas e iconos de tiendas | USD 0 | USD 50 a 300 | Puede hacerse internamente. |
| Politica de privacidad y terminos basicos | USD 0 | USD 50 a 300 | Necesario para tiendas. |
| Pruebas funcionales y correcciones | USD 0 | USD 200 a 1,000 | Depende del alcance de QA. |

Estos montos de contratacion son aproximados y dependen del pais, experiencia del desarrollador y cantidad de errores encontrados.

## 6. Costos de mantenimiento

### Escenario minimo: app gratuita sin backend

| Concepto | Costo anual estimado |
| --- | ---: |
| GitHub Pages | USD 0 |
| Google Play Console | USD 25 solo el primer ano |
| Apple Developer Program | USD 99 por ano |
| Dominio personalizado opcional | USD 10 a 20 por ano |
| Hosting de politica de privacidad | USD 0 si se usa GitHub Pages |

**Costo primer ano minimo:** aproximadamente USD 124, sin dominio y sin comprar Mac.

**Costo anual recurrente minimo despues del primer ano:** aproximadamente USD 99, principalmente por Apple Developer Program.

### Escenario con dominio propio

| Concepto | Costo anual estimado |
| --- | ---: |
| Apple Developer Program | USD 99 |
| Dominio propio | USD 10 a 20 |
| Web hosting con GitHub Pages | USD 0 |

**Costo anual estimado:** USD 109 a 119.

### Escenario con backend basico

Si ComuniCAA evoluciona a producto Freemium con usuarios, sincronizacion y almacenamiento remoto:

| Concepto | Costo mensual estimado |
| --- | ---: |
| Firebase/Supabase en capa gratuita | USD 0 |
| Firebase/Supabase con uso moderado | USD 5 a 25 |
| Almacenamiento de imagenes/audio | USD 0 a 20 |
| Base de datos y autenticacion | USD 0 a 25 |
| Monitoreo/analitica adicional | USD 0 a 20 |

**Costo mensual inicial realista con backend:** USD 0 a 50.

## 7. Comisiones por modelo Freemium

Si ComuniCAA se mantiene gratuita, no hay comisiones de venta.

Si se agregan funciones premium digitales dentro de la app, como suscripciones, paquetes de voces, sincronizacion premium o tableros avanzados, las tiendas pueden cobrar comision sobre esas ventas.

| Plataforma | Comision general aproximada | Observacion |
| --- | ---: | --- |
| App Store | 15% a 30% | 15% para desarrolladores elegibles en Small Business Program. |
| Google Play | Variable, frecuentemente 15% o menos para muchos desarrolladores; puede cambiar por region y tipo de transaccion | Revisar tarifa vigente al activar monetizacion. |
| Web propia | 2.9% + tarifa fija aprox. si se usa pasarela como Stripe/PayPal | Requiere backend o integracion de pagos. |

Para reducir complejidad inicial, se recomienda publicar primero la app gratuita y dejar la monetizacion premium para una segunda fase.

## 8. Presupuesto recomendado para ComuniCAA

### Ruta 1: Publicacion academica o demo

| Elemento | Costo |
| --- | ---: |
| Web en GitHub Pages | USD 0 |
| Documentacion en repositorio | USD 0 |
| Dominio propio | Opcional, USD 10 a 20/anual |

**Total recomendado:** USD 0 a 20.

Esta ruta es ideal para presentar el proyecto, compartirlo con docentes o validar la idea.

### Ruta 2: Publicacion Android publica

| Elemento | Costo |
| --- | ---: |
| Google Play Console | USD 25 pago unico |
| Web/privacidad en GitHub Pages | USD 0 |
| Dominio propio | Opcional, USD 10 a 20/anual |

**Total recomendado primer ano:** USD 25 a 45.

Esta ruta es la mas economica para lanzar ComuniCAA a usuarios reales en dispositivos Android.

### Ruta 3: Publicacion Android + iOS + Web

| Elemento | Costo |
| --- | ---: |
| GitHub Pages | USD 0 |
| Google Play Console | USD 25 pago unico |
| Apple Developer Program | USD 99 anual |
| Dominio propio | Opcional, USD 10 a 20 anual |

**Total minimo primer ano:** USD 124 a 144, si ya se cuenta con Mac o acceso a macOS.

Si no se cuenta con Mac, debe considerarse compra, prestamo o alquiler de entorno macOS para compilar y publicar iOS.

## 9. Recomendacion final

Para ComuniCAA, la estrategia mas conveniente es:

1. Publicar primero una version web en GitHub Pages para demostracion.
2. Crear una pagina publica de politica de privacidad usando el mismo GitHub Pages.
3. Publicar despues Android en Google Play, porque el costo es bajo y el proceso es mas accesible.
4. Publicar iOS cuando ya se tenga validacion del prototipo, acceso a Mac y presupuesto para la membresia anual de Apple.
5. Mantener el backend fuera de la primera publicacion, ya que el proyecto actual puede funcionar con assets locales.
6. Agregar backend y monetizacion Freemium en una fase posterior, cuando exista validacion con usuarios reales.

## 10. Fuentes oficiales consultadas

- Apple Developer Program: https://developer.apple.com/programs/enroll/
- App Store Small Business Program: https://developer-mdn.apple.com/app-store/small-business-program/
- App Store Connect - privacidad de apps: https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy
- App Store Connect - capturas y previews: https://developer.apple.com/help/app-store-connect/manage-app-information/upload-app-previews-and-screenshots
- Flutter - publicar app iOS: https://docs.flutter.dev/deployment/ios
- Google Play Console - registro: https://support.google.com/googleplay/android-developer/answer/6112435
- Google Play - requisitos de prueba para cuentas personales nuevas: https://support.google.com/googleplay/android-developer/answer/14151465
- GitHub Pages - limites: https://docs.github.com/en/enterprise-cloud@latest/pages/getting-started-with-github-pages/github-pages-limits
- GitHub Pages - dominio personalizado: https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site
- Firebase Pricing: https://firebase.google.com/pricing
