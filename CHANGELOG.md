# Bitácora de Cambios e Historial del Proyecto CERBERUS

Este archivo registra el historial de versiones, funciones implementadas, correcciones de errores y decisiones arquitectónicas del proyecto CERBERUS.

---

## [1.1.8+42] - 2026-11-09
### Edición F-Droid 100% offline
- **Sin conexión a internet**:
  - Eliminadas todas las dependencias y llamadas de red de la aplicación.
  - Sustituidos los iconos remotos de los sitios por avatares locales generados con la inicial y un color estable derivado del nombre del sitio.
  - Eliminada la consulta a Digital Asset Links; el autocompletado usa el dominio web o el nombre del paquete.
  - Sustituidas las fuentes descargadas en ejecución por las fuentes del sistema.
- **Sin servicios externos**:
  - Eliminados los componentes de cuentas externas, reseñas y almacenamiento remoto.
  - Eliminado el permiso de red del AndroidManifest; el APK no solicita acceso a internet.
- **Todas las funciones desbloqueadas**:
  - No existen bloqueos ni restricciones: todas las funciones están disponibles para todos los usuarios.
- **Copia de seguridad local cifrada**:
  - Se mantiene la exportación e importación de archivos cifrados (`.cjson`) con el mismo cifrado que la base de datos.

---

## [1.1.7+41] - 2026-09-16
### Preparación de la edición F-Droid
- Metadatos de publicación adaptados para el repositorio oficial de F-Droid.
- Compilación estándar de Flutter y funciones de la aplicación disponibles sin restricciones.

---

## [1.1.6+40] - 2026-07-29
### Añadido / Compilación
- **Compilación de Producción App Bundle (`.aab`)**:
  - Incrementada la versión a `1.1.6+40`.
  - Generación de Android App Bundle (`app-release.aab`) para publicación en Google Play Store con los nuevos modelos de evaluación de contraseñas y diversidad de caracteres.

---

## [1.1.5+39] - 2026-07-29
### Añadido / Mejorado
- **Cálculo Explícito de Diversidad de Caracteres en $P_{\text{base}}$**:
  - Actualizada la función `calculatePasswordScore` en `SecurityHealthService` para computar `characterSetsCount` (del 1 al 4) escaneando minúsculas `[a-z]`, mayúsculas `[A-Z]`, números `[0-9]` y símbolos `[^a-zA-Z0-9]`.
  - **Escenario A ($P_{\text{base}} = 30$ pts - Débil)**: Se asigna si la longitud es $<8$, es una clave común o posee un único conjunto de caracteres (`characterSetsCount <= 1`).
  - **Escenario C ($P_{\text{base}} = 100$ pts - Fuerte)**: Se exige longitud $\ge 12$ y presencia de al menos 3 tipos de caracteres distintos (`characterSetsCount >= 3`).
  - **Escenario B ($P_{\text{base}} = 70$ pts - Media)**: Asignación intermedia (ej. 8-11 caracteres con $\ge 2$ tipos, o $\ge 12$ caracteres con exactamente 2 tipos).

---

## [1.1.4+38] - 2026-07-28
### Añadido / Mejorado
- **Nuevo Modelo Ponderado de Salud de Seguridad (`SecurityHealthService`)**:
  - Implementado cálculo de fortaleza individual por puntuación $P_i$ (0-100 pts) considerando longitud (diferenciando $<8$, $8\text{--}11$ y $\ge 12$ caracteres), coincidencia con contraseñas comunes y penalización severa por reutilización.
  - Implementada fórmula de puntuación global ponderada $Score_{base} = \frac{\sum P_i}{N}$.
  - Implementados **límites de riesgo crítico (Caps)** sobre el puntaje global:
    - **Cap del 50%** si existe al menos 1 contraseña de riesgo crítico ($P_i \le 40$).
    - **Cap del 60%** si la tasa de reutilización de contraseñas supera el 30%.
- **Indicador y Aviso Visual en la UI**:
  - Añadido distintivo de advertencia en la pantalla de salud de seguridad (`SecurityHealthScreen`) cuando la puntuación global está limitada por un riesgo crítico (`isCapped == true`).
  - Actualizados los colores e indicadores de estado en `home_screen.dart` para alinearse con los nuevos rangos de puntuación del servicio.

---

## [1.1.3+37] - 2026-07-26
### Añadido / Mejorado
- **Autocompletado Web para Android (Chrome, Firefox, Edge)**:
  - Actualizado `CerberusAutofillService.kt` para rastrear elementos HTML `<input>` (`type="password"`, `type="email"`, `name`, `id`, `autocomplete`) en WebViews y páginas web.
  - Implementada extracción del dominio web (`webDomain`) y pasado a Flutter vía `MethodChannel`.
  - Actualizado `autofill_handler_service.dart` para filtrar credenciales en la base de datos de Cerberus según el dominio web de la página activa.
  - Añadida la propiedad `android:settingsActivity="com.dsvdevelopment.cerberus.MainActivity"` en `autofill_service_config.xml` para mejor visibilidad y registro en Samsung One UI.

---

## [1.1.2+36] - 2026-07-26
### Añadido / Mejorado
- **Galería de Adjuntos en la Tarjeta**:
  - Reemplazado el carrusel horizontal por una lista vertical en columna donde los adjuntos ocupan el **100% del ancho de la tarjeta**.
  - Si hay varias imágenes o archivos, se apilan verticalmente uno debajo del otro.
- **Visor de Imágenes a Pantalla Completa**:
  - Creado el widget `_FullScreenImageViewer` utilizando `InteractiveViewer` y `SizedBox.expand` sobre fondo negro.
  - Las imágenes maximizadas ocupan el 100% de la pantalla manteniendo la proporción tanto en vertical como en horizontal (landscape).
  - Al hacer zoom, la imagen se amplía y se puede desplazar por todo el viewport de la pantalla sin cortes negros estáticos.
- **Formato de URL en Minúsculas**:
  - Configurado `textCapitalization: TextCapitalization.none` para el campo de Sitio Web (`websiteController`) y campos personalizados cuya etiqueta contenga `web`, `url` o `sitio`.

---

## [1.1.1+35] - 2026-07-26
### Correcciones
- **Apertura de PDFs y Archivos Adjuntos**:
  - Corregido error por el cual los PDFs no abrían al tocarlos debido a que la consulta ligera del listado no cargaba `fileBytes`.
  - Actualizado `AttachmentService.viewAttachment` para consultar `getAttachmentData(id)` y cargar el blob binario antes de abrir con `OpenFilex`.
  - Añadida gestión de errores asíncrona con `SnackBar` en la interfaz.

---

## [1.1.0+34] - 2026-07-26
### Añadido / Mejorado
- **Capitalización Automática**:
  - Activado `textCapitalization: TextCapitalization.sentences` para título, notas y campos dinámicos generales (excluyendo usuarios, correos y contraseñas).
- **Indicador Gris para Tarjetas sin Contraseña**:
  - Si una tarjeta no posee contraseña, el indicador visual de seguridad y el gradiente de la tarjeta cambian a color **gris**.
- **Privacidad al pasar a Segundo Plano**:
  - Implementado `navigatorKey` en `MaterialApp` de `main.dart`.
  - Al cerrar la sesión por inactividad (`_handleLogout`), se fuerzan el cierre de todos los diálogos y detalles de tarjetas abiertos mediante `popUntil((route) => route.isFirst)`.
