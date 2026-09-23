# Documentacion del Proyecto ComuniCAA

## Introduccion

ComuniCAA es un prototipo funcional desarrollado en Flutter para apoyar procesos de Comunicacion Aumentativa y Alternativa (CAA). La aplicacion permite construir mensajes mediante pictogramas, organizar vocabulario por categorias y carpetas, buscar palabras, escribir frases manuales y reproducir el mensaje mediante audios pregrabados o Text-to-Speech (TTS).

El proyecto actual corresponde a una solucion movil hibrida y cross-platform, preparada para ejecutarse en Android, iOS y Web desde una misma base de codigo Dart/Flutter. Su alcance actual es principalmente frontend/prototipo funcional, con datos locales iniciales, recursos visuales y archivos de audio incluidos en el repositorio.

---

# Fase I

## 1. Modelo de Negocio: Freemium

El modelo de negocio propuesto para ComuniCAA es **Freemium**, ya que permite ofrecer una version gratuita con funciones esenciales de comunicacion y una version premium con capacidades avanzadas de personalizacion, seguimiento y soporte.

### Version gratuita

La version gratuita debe cubrir las necesidades principales del usuario final:

- Acceso al tablero basico de comunicacion.
- Uso de pictogramas predefinidos por categorias.
- Construccion de mensajes mediante seleccion de pictogramas.
- Reproduccion de mensajes con audios pregrabados disponibles.
- Uso de TTS cuando no exista audio pregrabado para un pictograma.
- Busqueda de pictogramas.
- Escritura de frases manuales mediante teclado.
- Ajustes basicos de accesibilidad visual.

### Version premium

La version premium puede orientarse a familias, cuidadores, terapeutas, centros educativos o clinicas:

- Creacion ilimitada de pictogramas personalizados.
- Creacion y organizacion avanzada de carpetas.
- Perfiles multiples de usuario con tableros diferenciados.
- Sincronizacion en la nube.
- Respaldo y restauracion de tableros.
- Estadisticas de uso de pictogramas y frases frecuentes.
- Exportacion/importacion de tableros.
- Voces premium o paquetes adicionales de audio.
- Soporte especializado para instituciones educativas o terapeuticas.

### Justificacion del modelo

El modelo Freemium es adecuado porque ComuniCAA atiende una necesidad social y educativa sensible. La version gratuita reduce la barrera de acceso para usuarios que necesitan una herramienta de comunicacion inmediata, mientras que las funciones premium permiten sostenibilidad economica sin bloquear la funcionalidad esencial.

## 2. Tipo de Aplicacion

ComuniCAA se clasifica tecnicamente como una **aplicacion movil hibrida, cross-platform**.

### Clasificacion tecnica

- **Movil hibrida:** se desarrolla con Flutter, framework que permite crear aplicaciones con una unica base de codigo y desplegarlas en diferentes plataformas.
- **Cross-platform:** el proyecto incluye estructura para Android, iOS y Web.
- **Frontend funcional:** la version actual se centra en la interfaz, interaccion del usuario, manejo de estado local, pictogramas y reproduccion de audio.
- **Aplicacion accesible:** incorpora configuraciones visuales y de interaccion orientadas a usuarios con necesidades comunicativas diversas.

### Evidencia en el proyecto

| Elemento | Evidencia |
| --- | --- |
| Framework principal | `pubspec.yaml` declara Flutter y Dart SDK `>=3.3.0 <4.0.0`. |
| Android | Carpeta `android/` con configuracion Gradle y `AndroidManifest.xml`. |
| iOS | Carpeta `ios/` con configuracion de Runner e iconos. |
| Web | Carpeta `web/` con `index.html`, `manifest.json` e iconos web. |
| Estado local | Uso de `provider` en `lib/main.dart` y proveedores en `lib/providers/`. |
| Multimedia | Assets de pictogramas en `assets/pictograms/imported/` y audios en `assets/audio/pictograms/`. |

## 3. Presentacion de Logica Funcional

El flujo principal de ComuniCAA permite construir una frase a partir de pictogramas. Cada pictograma posee una etiqueta visible, un texto asociado para pronunciacion y, cuando existe, un archivo de audio pregrabado.

### Flujo basico del mensaje

1. El usuario visualiza el tablero de pictogramas.
2. El usuario selecciona un pictograma.
3. El sistema identifica el pictograma seleccionado.
4. El pictograma se incorpora a una estructura temporal que representa el mensaje en construccion.
5. El usuario puede repetir el proceso hasta formar la expresion deseada.
6. El usuario ejecuta la accion **Hablar**.
7. El sistema genera la frase textual a partir de los pictogramas seleccionados.
8. El servicio de audio intenta reproducir los audios pregrabados correspondientes.
9. Si un audio no esta disponible, el sistema utiliza Text-to-Speech (TTS).
10. El mensaje se transforma en salida de voz.

### Representacion textual del flujo

```text
Inicio
  |
  v
Usuario selecciona pictograma
  |
  v
Sistema obtiene label, spokenText, categoria, imagen y audioPath
  |
  v
CommunicationProvider agrega el pictograma al mensaje temporal
  |
  v
Se actualiza la barra de mensaje
  |
  v
Usuario repite seleccion o presiona "Hablar"
  |
  v
Sistema construye la frase final
  |
  v
PictogramAudioService reproduce audio pregrabado si existe
  |
  v
Si no existe audio, se usa Text-to-Speech
  |
  v
Salida audible del mensaje
Fin
```

### Componentes funcionales relacionados

| Componente | Funcion |
| --- | --- |
| `CommunicationProvider` | Mantiene la lista temporal de pictogramas y textos que forman el mensaje. |
| `MessageBar` | Muestra el mensaje en construccion y ofrece acciones de hablar, borrar ultima palabra y limpiar. |
| `PictogramAudioService` | Reproduce audio pregrabado o usa TTS como alternativa. |
| `PictogramProvider` | Administra pictogramas, favoritos, carpetas, busqueda y tablero. |
| `SettingsProvider` | Administra accesibilidad, modo cuidador, densidad del tablero y configuraciones visuales. |

## 4. Metodologia de Desarrollo: Prototipado Evolutivo

La metodologia seleccionada es **Prototipado Evolutivo**. Esta metodologia permite construir una version inicial funcional, evaluarla con usuarios o responsables del proyecto, recoger retroalimentacion y mejorar el producto en ciclos sucesivos.

### Justificacion

ComuniCAA es una aplicacion centrada en experiencia de usuario, accesibilidad y necesidades comunicativas. En este tipo de proyecto, los requisitos pueden cambiar despues de observar como interactuan los usuarios con el tablero, los pictogramas, la organizacion por categorias y la reproduccion de voz. Por ello, el prototipado evolutivo resulta adecuado.

### Ciclos propuestos

| Iteracion | Objetivo | Resultado esperado |
| --- | --- | --- |
| Prototipo 1 | Crear tablero inicial de pictogramas y categorias. | Usuario puede navegar y seleccionar pictogramas. |
| Prototipo 2 | Construir barra de mensaje y accion de hablar. | Usuario forma frases y escucha salida de voz. |
| Prototipo 3 | Agregar busqueda, teclado y favoritos. | Usuario encuentra vocabulario con mayor rapidez. |
| Prototipo 4 | Incorporar modo cuidador y edicion de pictogramas/carpetas. | Responsable puede personalizar el tablero. |
| Prototipo 5 | Mejorar accesibilidad visual y portabilidad. | Interfaz adaptable a diferentes usuarios y dispositivos. |

### Evidencia en el proyecto

La estructura del proyecto refleja una evolucion incremental:

- `lib/screens/communication/communication_screen.dart`: pantalla principal de comunicacion.
- `lib/widgets/message_bar.dart`: construccion y reproduccion del mensaje.
- `lib/screens/search/search_screen.dart`: busqueda de pictogramas.
- `lib/screens/keyboard/keyboard_screen.dart`: ingreso manual de frases.
- `lib/screens/editor/pictogram_editor_screen.dart`: creacion y edicion de pictogramas/carpetas.
- `lib/screens/settings/settings_screen.dart`: ajustes visuales y de comunicacion.
- `lib/providers/`: separacion del estado por responsabilidad.
- `assets/`: incorporacion progresiva de pictogramas, categorias y audios.

## 5. Estandar de Calidad a Utilizar: ISO 9126

El estandar de calidad elegido es **ISO/IEC 9126**, orientado a evaluar la calidad del producto software mediante caracteristicas internas y externas.

### Caracteristicas aplicadas a ComuniCAA

| Caracteristica ISO 9126 | Aplicacion en ComuniCAA |
| --- | --- |
| Funcionalidad | La app permite seleccionar pictogramas, construir mensajes, buscar vocabulario, escribir frases y reproducir voz. |
| Fiabilidad | El servicio de audio tiene mecanismo alternativo: si no existe audio pregrabado, intenta TTS. |
| Usabilidad | La interfaz usa pictogramas, categorias, botones grandes, alto contraste, escala de texto y configuracion visual. |
| Eficiencia | El estado se maneja con `provider`, listas filtradas y widgets reutilizables. |
| Mantenibilidad | El codigo esta separado en modelos, proveedores, servicios, pantallas, widgets, tema y datos. |
| Portabilidad | Flutter permite ejecucion en Android, iOS y Web desde una misma base de codigo. |

## 6. Herramientas de Desarrollo y Plataforma Tecnologica

### Herramientas principales

| Herramienta / Tecnologia | Uso en el proyecto |
| --- | --- |
| Flutter | Framework principal para construir la aplicacion cross-platform. |
| Dart | Lenguaje de programacion utilizado por Flutter. |
| Material Design | Base visual de componentes de interfaz. |
| Provider | Gestion de estado local mediante `ChangeNotifier`. |
| Flutter TTS | Conversion de texto a voz. |
| Audioplayers | Reproduccion de audios pregrabados. |
| Flutter SVG | Renderizado de imagenes SVG, incluyendo placeholders. |
| Image Picker | Seleccion o captura de imagenes para pictogramas personalizados. |
| Path Provider | Acceso a almacenamiento local de la aplicacion. |
| Web package | Interoperabilidad con funciones web para reproduccion de secuencias de audio. |
| Flutter Test | Pruebas automatizadas de widgets. |
| Flutter Lints | Reglas de calidad y estilo para codigo Dart. |

### Sistema operativo y entornos objetivo

| Elemento | Detalle |
| --- | --- |
| Sistema de desarrollo observado | Windows, segun rutas del proyecto y scripts `.bat`. |
| Plataformas objetivo | Android, iOS y Web. |
| Version del proyecto | `0.1.0+1`, declarada en `pubspec.yaml`. |
| Tipo de almacenamiento actual | Datos locales en memoria, assets incluidos y almacenamiento local para imagenes personalizadas. |
| Backend | No se observa backend integrado en la version actual. |

### Recursos del proyecto

| Recurso | Cantidad observada | Ubicacion |
| --- | ---: | --- |
| Pictogramas importados | 101 | `assets/pictograms/imported/` |
| Audios de pictogramas | 102 | `assets/audio/pictograms/` |
| Imagenes de categorias | 7 | `assets/categories/` |
| Categorias iniciales | 8 | `lib/data/mock_categories.dart` |
| Perfiles iniciales | 3 | `lib/data/mock_users.dart` |

---

# Fase II

## 1. Detalles del Producto Funcional: Solucion Tecnologica

ComuniCAA es una solucion tecnologica para crear mensajes comunicativos mediante pictogramas. Esta orientada a usuarios que requieren apoyo visual y auditivo para expresar necesidades, emociones, acciones, lugares, personas u objetos.

### Modulos funcionales

| Modulo | Descripcion funcional | Archivos relacionados |
| --- | --- | --- |
| Tablero de comunicacion | Muestra pictogramas disponibles para construir mensajes. | `communication_screen.dart`, `pictogram_grid.dart`, `pictogram_card.dart` |
| Barra de mensaje | Presenta el mensaje temporal y permite hablar, borrar o limpiar. | `message_bar.dart`, `message_pictogram.dart` |
| Categorias y carpetas | Organiza pictogramas por grupos visuales y carpetas. | `category_folder_strip.dart`, `categories_screen.dart`, `category_pictograms_screen.dart` |
| Busqueda | Permite localizar pictogramas por etiqueta o texto hablado. | `search_screen.dart`, `PictogramProvider.search()` |
| Teclado | Permite agregar frases manuales al mensaje. | `keyboard_screen.dart`, `CommunicationProvider.setManualSentence()` |
| Editor | Permite crear o editar pictogramas y carpetas con imagen personalizada. | `pictogram_editor_screen.dart`, `pictogram_editor_panel.dart` |
| Ajustes | Permite modificar apariencia, accesibilidad, tablero y comunicacion. | `settings_screen.dart`, `SettingsProvider` |
| Audio y TTS | Reproduce voz usando audios locales o TTS. | `pictogram_audio_service.dart` |

### Funciones principales disponibles

- Construccion de mensajes con pictogramas.
- Reproduccion del mensaje completo.
- Reproduccion inmediata al tocar pictogramas, si se activa la opcion.
- Eliminacion de la ultima palabra seleccionada.
- Limpieza completa del mensaje.
- Busqueda de pictogramas por texto.
- Uso de frases manuales.
- Organizacion por categorias: Esenciales, Personas, Comida, Emociones, Lugares, Actividades, Objetos y Favoritos.
- Gestion de favoritos.
- Creacion de pictogramas personalizados.
- Creacion de carpetas.
- Agregado de pictogramas a carpetas.
- Configuracion de tema claro/oscuro.
- Alto contraste.
- Escalado de texto.
- Densidad del tablero: amplio, compacto y denso.
- Ubicacion de barra de carpetas: arriba, abajo u oculta.
- Ajuste de tamano de pictogramas y barra de comunicacion.

### Alcance actual

La version actual funciona como prototipo frontend con datos locales. Esto significa que permite demostrar y validar la experiencia central de comunicacion, pero aun no incorpora servicios de backend como autenticacion, sincronizacion en la nube, pagos, panel administrativo remoto o base de datos persistente compartida.

## 2. Evidencia Documentada de Metodologia de Desarrollo Aplicada por el Grupo

La metodologia de Prototipado Evolutivo se evidencia en la forma en que el proyecto se encuentra organizado por modulos funcionales independientes. Cada modulo representa una mejora incremental sobre el prototipo base.

### Evidencia por incremento

| Incremento | Evidencia tecnica | Interpretacion metodologica |
| --- | --- | --- |
| Tablero inicial | `CommunicationScreen`, `PictogramGrid`, `PictogramCard` | Primer prototipo usable para seleccionar pictogramas. |
| Mensaje temporal | `CommunicationProvider`, `MessageBar` | Mejora del prototipo para formar expresiones completas. |
| Audio | `PictogramAudioService`, `assets/audio/pictograms/` | Iteracion orientada a convertir el mensaje visual en salida oral. |
| Organizacion | `CategoryProvider`, `CategoryFolderStrip`, carpetas en `PictogramProvider` | Mejora para ordenar vocabulario y facilitar acceso. |
| Personalizacion | `PictogramEditorScreen`, `image_picker`, `path_provider` | Iteracion para adaptar el tablero al contexto del usuario. |
| Accesibilidad | `SettingsProvider`, `SettingsScreen`, alto contraste, escala de texto | Iteracion centrada en diversidad de usuarios. |
| Pruebas iniciales | `test/widget_test.dart` | Validacion automatizada basica de carga de interfaz. |

### Actividades recomendadas para documentar por el grupo

Para presentar evidencia formal de la metodologia, se recomienda mantener los siguientes registros:

| Documento / Registro | Contenido |
| --- | --- |
| Bitacora de iteraciones | Fecha, objetivo del prototipo, cambios realizados y responsable. |
| Historias de usuario | Necesidad del usuario, criterio de aceptacion y prioridad. |
| Registro de retroalimentacion | Observaciones de usuarios, cuidadores o docentes durante pruebas. |
| Acta de validacion | Resultado de revision de cada prototipo. |
| Lista de cambios | Funciones agregadas, corregidas o eliminadas por iteracion. |
| Evidencia visual | Capturas de pantalla del tablero, barra de mensaje, ajustes y editor. |

### Ejemplo de historias de usuario del proyecto

| Historia de usuario | Criterio de aceptacion |
| --- | --- |
| Como usuario, quiero seleccionar pictogramas para expresar una frase. | Al tocar pictogramas, estos aparecen en la barra de mensaje en el orden seleccionado. |
| Como usuario, quiero escuchar el mensaje construido. | Al presionar hablar, el sistema reproduce audios o TTS con la frase formada. |
| Como cuidador, quiero personalizar pictogramas. | En modo cuidador se puede crear un pictograma con nombre, texto hablado e imagen. |
| Como usuario, quiero encontrar palabras rapidamente. | La pantalla de busqueda muestra pictogramas que coinciden con el texto ingresado. |
| Como cuidador, quiero ajustar la visualizacion. | La pantalla de ajustes permite modificar contraste, texto, densidad y tamano de elementos. |

## 3. Aplicacion del Estandar de Calidad ISO 9126

La aplicacion de ISO 9126 en ComuniCAA se plantea mediante criterios observables y verificables sobre el producto.

### Matriz de calidad

| Caracteristica | Subcaracteristica aplicada | Criterio en ComuniCAA | Evidencia |
| --- | --- | --- | --- |
| Funcionalidad | Adecuacion | La app permite construir mensajes con pictogramas y texto. | `CommunicationProvider`, `MessageBar` |
| Funcionalidad | Exactitud | El texto hablado se genera desde `spokenText` y se normaliza como frase. | `getSentence()` |
| Funcionalidad | Interoperabilidad | Uso de audio local, TTS y adaptacion Web con JS interop. | `pictogram_audio_service.dart`, `pictogram_audio_sequence_player_web.dart` |
| Fiabilidad | Tolerancia a fallos | Si no existe audio, se intenta TTS; si falla, se evita interrumpir la app. | Bloques `try/catch` en servicio de audio. |
| Usabilidad | Comprensibilidad | Interfaz visual por pictogramas, categorias y botones con iconos. | Widgets de pictogramas y navegacion inferior. |
| Usabilidad | Operabilidad | Acciones directas: hablar, borrar, limpiar, buscar, agregar. | `MessageBar`, `SearchScreen`, `KeyboardScreen` |
| Usabilidad | Accesibilidad | Alto contraste, escala de texto, densidad, botones grandes y soporte semantico. | `SettingsProvider`, `Semantics` |
| Eficiencia | Comportamiento temporal | Uso de listas, filtros y estado local sin llamadas remotas. | `PictogramProvider`, `CategoryProvider` |
| Eficiencia | Uso de recursos | Assets locales reducen dependencia de red para pictogramas y audios. | Carpetas `assets/` |
| Mantenibilidad | Analizabilidad | Separacion por modelos, proveedores, pantallas, servicios y widgets. | Estructura `lib/` |
| Mantenibilidad | Modificabilidad | Nuevas funciones pueden agregarse por modulo sin alterar toda la app. | Arquitectura por providers/widgets. |
| Portabilidad | Adaptabilidad | Flutter permite adaptar la aplicacion a movil y web. | Carpetas `android/`, `ios/`, `web/` |
| Portabilidad | Instalabilidad | El proyecto puede ejecutarse con `flutter pub get` y `flutter run`. | `README.md` |

### Indicadores sugeridos

| Indicador | Meta sugerida |
| --- | --- |
| Tiempo para construir una frase simple | Menor a 10 segundos en tablero principal. |
| Comprension de iconos principales | Mayor al 80% en prueba con usuarios. |
| Reproduccion correcta de mensajes | Mayor al 95% en pruebas funcionales. |
| Fallos criticos durante uso basico | 0 durante pruebas de aceptacion. |
| Compatibilidad de pantalla | Correcta visualizacion en movil, tablet y navegador web. |
| Accesibilidad visual | Texto legible con escala aumentada y alto contraste activo. |

## 4. Metodologias de Pruebas Aplicadas al Producto

Para validar ComuniCAA se recomienda combinar pruebas automatizadas y manuales, debido a que el producto depende tanto de logica interna como de experiencia de usuario, accesibilidad, audio y usabilidad.

### Pruebas automatizadas

| Tipo de prueba | Objetivo | Herramienta |
| --- | --- | --- |
| Pruebas de widgets | Verificar que las pantallas principales carguen correctamente. | `flutter_test` |
| Pruebas de proveedores | Validar logica de mensajes, pictogramas, carpetas y ajustes. | `flutter_test` |
| Pruebas de regresion | Confirmar que nuevas iteraciones no rompan flujos existentes. | `flutter test` |
| Analisis estatico | Detectar problemas de estilo o posibles errores. | `flutter analyze` |

### Evidencia actual de pruebas

El proyecto ya incluye una prueba inicial en `test/widget_test.dart`. Esta prueba monta la aplicacion con sus proveedores principales y valida elementos visibles de la pantalla de comunicacion.

### Casos de prueba funcionales recomendados

| ID | Caso de prueba | Pasos | Resultado esperado |
| --- | --- | --- | --- |
| PF-01 | Agregar pictograma al mensaje | Seleccionar un pictograma del tablero. | El pictograma aparece en la barra de mensaje. |
| PF-02 | Reproducir mensaje | Agregar pictogramas y presionar hablar. | Se reproduce audio pregrabado o TTS. |
| PF-03 | Borrar ultima palabra | Agregar varios pictogramas y presionar borrar. | Se elimina solo el ultimo elemento. |
| PF-04 | Limpiar mensaje | Agregar pictogramas y presionar limpiar. | La barra de mensaje queda vacia. |
| PF-05 | Buscar pictograma | Ingresar una palabra en busqueda. | Se muestran coincidencias por etiqueta o texto hablado. |
| PF-06 | Agregar frase manual | Escribir frase en teclado y agregar al mensaje. | El texto se integra al mensaje temporal. |
| PF-07 | Crear pictograma | En modo cuidador, crear pictograma con nombre e imagen. | El pictograma queda disponible en el tablero/categoria. |
| PF-08 | Crear carpeta | En modo cuidador, crear carpeta con imagen. | La carpeta aparece como elemento del tablero. |
| PF-09 | Cambiar contraste | Activar alto contraste en ajustes. | La interfaz cambia a una combinacion mas legible. |
| PF-10 | Cambiar densidad | Seleccionar amplio, compacto o denso. | La cuadricula ajusta columnas y espaciado. |

### Pruebas de usabilidad

Estas pruebas deben realizarse con usuarios representativos, cuidadores o docentes:

- Identificar si el usuario comprende los pictogramas.
- Medir el tiempo para crear frases comunes.
- Observar si los botones de hablar, borrar y limpiar son comprensibles.
- Evaluar si la busqueda mejora el acceso a vocabulario.
- Validar si la densidad del tablero se adapta a diferentes capacidades visuales o motoras.
- Registrar comentarios sobre tamano, contraste, ubicacion de carpetas y orden de categorias.

### Pruebas de accesibilidad

| Aspecto | Verificacion |
| --- | --- |
| Escala de texto | Aumentar texto y verificar que la interfaz siga siendo legible. |
| Alto contraste | Activar contraste y revisar diferenciacion de elementos. |
| Botones grandes | Validar facilidad de seleccion tactil. |
| Semantica | Revisar etiquetas semanticas en acciones principales. |
| Reduccion de complejidad | Evaluar modo simplificado y densidad adecuada para el usuario. |

### Pruebas de compatibilidad

| Plataforma | Verificacion |
| --- | --- |
| Android | Instalacion, navegacion, seleccion de imagenes y reproduccion de audio. |
| iOS | Permisos de galeria/camara, audio y visualizacion. |
| Web | Carga del tablero, reproduccion secuencial de audio y responsividad. |
| Tablet | Distribucion de cuadricula, barra de mensaje y carpetas. |
| Movil | Legibilidad, navegacion inferior y seleccion tactil. |

### Pruebas de aceptacion

La prueba de aceptacion debe confirmar que el producto cumple el objetivo principal:

> El usuario puede construir una frase mediante pictogramas o texto, visualizarla en la barra de mensaje y reproducirla como voz de forma comprensible.

#### Criterios de aceptacion generales

- El usuario puede seleccionar pictogramas sin errores visibles.
- El sistema conserva el orden de seleccion en el mensaje.
- La accion hablar reproduce el contenido del mensaje.
- La app permite corregir el mensaje antes de hablar.
- El cuidador puede personalizar elementos basicos.
- La interfaz se adapta mediante ajustes de accesibilidad.

---

# Conclusiones

ComuniCAA presenta una base solida como prototipo funcional de Comunicacion Aumentativa y Alternativa. La seleccion de Flutter permite un desarrollo cross-platform, mientras que la arquitectura por modelos, proveedores, servicios, pantallas y widgets facilita la evolucion progresiva del producto.

El modelo Freemium es coherente con el proposito social de la aplicacion, porque permite acceso gratuito a funciones esenciales y reserva capacidades avanzadas para sostener el producto. La metodologia de Prototipado Evolutivo se ajusta al proyecto porque el valor principal depende de probar, observar y adaptar la experiencia a usuarios reales.

La aplicacion del estandar ISO 9126 permite evaluar ComuniCAA desde funcionalidad, fiabilidad, usabilidad, eficiencia, mantenibilidad y portabilidad. Finalmente, las pruebas propuestas combinan validacion automatizada, funcional, de accesibilidad, compatibilidad y aceptacion, cubriendo tanto la calidad tecnica como la experiencia comunicativa del usuario.
